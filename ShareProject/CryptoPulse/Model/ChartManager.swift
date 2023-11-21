//
//  ChartManager.swift
//  ShareProject
//
//  Created by Vitaly on 13.09.2023.
//

import Foundation
import LightweightCharts

final class ChartManager {
    weak var delegate: ChartViewController!
    var alarmManager: AlarmManager!
    var candleStickDataManager: CandleStickDataManager
    var chartManagerUI: ChartManagerUI?
    
    var symbol: String
    var timeFrame: String
    var isFirstKline = true
    var numberAfterDecimalPoint: String = "2" {
        didSet {
            updateFormat()
        }
    }
    
    private var chart: LightweightCharts?
    var series: CandlestickSeries?
    var isWasShown = true
    var currentCursorPrice: Double?
    
    var data = [CandlestickData]()
    
    private var currentBusinessDay = Date().timeIntervalSince1970
    lazy var currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
    
    init(delegate: ChartViewController, symbol: String, timeFrame: String, candleStickDataManager: CandleStickDataManager) {
        self.delegate = delegate
        self.symbol = symbol
        self.timeFrame = timeFrame
        self.candleStickDataManager = candleStickDataManager
    }
    
    func setup() {
        setupChart()
        setupSubscription()
        fetchCandlesData()
    }
    
    private func fetchCandlesData() {
        delegate.candleStickDataManager.fetchCandles(from: symbol, timeFrame: timeFrame) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                guard let delegate = self?.delegate else { return }
                self?.data = (delegate.candleStickDataManager.parseJSON(marketData: data))
                DispatchQueue.main.async {
                    self?.setupSeries()
                    if let firstCandle = self?.data.first?.close, firstCandle < 1 {
                        self?.numberAfterDecimalPoint = "4"
                    }
                }

                self?.delegate?.startWebSocketManagers()
            }
        }
    }
    
    private func setupChart() {
        let options = ChartOptions(timeScale: TimeScaleOptions(borderVisible: true,
                                                               timeVisible: true,
                                                               secondsVisible: true,
                                                               ticksVisible: true),
                                   crosshair: CrosshairOptions(mode: .normal),
                                   localization: LocalizationOptions(priceFormatter: .javaScript("function(price) { return '$' + price.toFixed(\(numberAfterDecimalPoint)); }")),
                                   trackingMode: TrackingModeOptions(exitMode: .onTouchEnd))

        
        let chart = LightweightCharts(options: options)
        alarmManager = AlarmManager(chartManager: self)
        alarmManager?.setupAlarmLines()
        
        chartManagerUI = ChartManagerUI(delegate: delegate)
        chartManagerUI?.setupUI(chart: chart)
        
        self.chart = chart
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenu), name: NSNotification.Name(rawValue: "anyBtnPressed"), object: nil)
    }
    
    private func setupSeries() {
        series = chart?.addCandlestickSeries(options: nil)
        data.removeLast()
        series?.setData(data: data)
        delegate.alarmManager?.setupAlarmLines()
    }
    
    func tick() {
        if isFirstKline {
            if let open = Double(delegate.currentCandelModel.openPrice),
               let high = Double(delegate.currentCandelModel.highPrice),
               let low = Double(delegate.currentCandelModel.lowPrice),
               let close = Double(delegate.currentCandelModel.openPrice) {
                currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: open, high: high, low: low, close: close)
                isFirstKline = false
            }
        }

        if delegate.isKlineClose {
            if let nextMinute = nextCandle(currentBusinessDay) {
                currentBusinessDay = nextMinute
                currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
            }
        }
        mergeTickToBar(delegate.closePrice)
    }
    
    private func mergeTickToBar(_ price: BarPrice) {
        if currentBar.open == nil {
            currentBar.open = price
            currentBar.high = price
            currentBar.low = price
            currentBar.close = price
        } else {
            currentBar.close = price
            currentBar.high = max(currentBar.high ?? price, price)
            currentBar.low = min(currentBar.low ?? price, price)
        }
        series?.update(bar: currentBar)
    }
    
    private func nextCandle(_ time: TimeInterval) -> TimeInterval? {
        let date = Date(timeIntervalSince1970: time)
        var dateComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
        dateComponents.minute! += 1
        guard let timeInterval = Calendar.current.date(from: dateComponents)?.timeIntervalSince1970 else {
            print("Error in nextMinute methode, can't get TimeInterval")
            return nil
        }
        
        return timeInterval
    }
    
    private func updateFormat() {
        chart?.applyOptions(options: ChartOptions(localization: LocalizationOptions(priceFormatter: .javaScript("function(price) { return '$' + price.toFixed(\(numberAfterDecimalPoint)); }"))))
    }
    
    private func setupSubscription() {
        chart?.delegate = self
        chart?.subscribeCrosshairMove()
    }
}
    
//    @objc func dragTheView(recognizer: UIPanGestureRecognizer) {
//        if recognizer.state == .began {
//
//        } else if recognizer.state == .changed {
//            let translation = recognizer.translation(in: self.chart)
//
////            let newX = alarmIndicator.center.x + translation.x
//            let newY = alarmIndicator.center.y + translation.y
//
//            alarmIndicator.center = CGPoint(x: 40, y: newY)
//            recognizer.setTranslation(CGPoint.zero, in: self.chart)
//
//        } else if recognizer.state == .ended {
//
//        }
//    }

// MARK: - ChartDelegate Methods
extension ChartManager: ChartDelegate {
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        guard case .utc(timestamp: _) = parameters.time,
              let point = parameters.point,
              case let .barData(data) = parameters.price(forSeries: series!),
              let open = data.open,
              let high = data.high,
              let low = data.low,
              let close = data.close else {
                  
            handleViewsVisibilityOnFailure(parameters: parameters)
            return
        }

        updateViews(with: open, high: high, low: low, close: close, point: point)
        updateCurrentCursorPrice(from: point.y)
        toggleDisplayViews(isHidden: false)
    }
    
    private func updateViews(with open: Double, high: Double, low: Double, close: Double, point: Point) {
        chartManagerUI?.tooltipView.update(title: "o:\(open), h:\(high), l:\(low), c:\(close)")
        chartManagerUI?.bottomConstraintForPercent?.constant = CGFloat(point.y) - 17
        chartManagerUI?.leadingConstraint?.constant = CGFloat(point.x) + 5
        chartManagerUI?.bottomConstraint?.constant = CGFloat(point.y) + 5
        isWasShown = false
    }

    private func updateCurrentCursorPrice(from coordinate: Double) {
        series?.coordinateToPrice(coordinate: coordinate) { [self] price in
            guard let price = price else { return }
            currentCursorPrice = price
            let percentChange = ((price * 100) / (delegate?.closePrice ?? 0) - 100)
            chartManagerUI?.percentChange.update(title: String(format: "%.2f%", percentChange))
        }
        chartManagerUI?.rightClickMenu.isHidden = true
    }

    private func toggleDisplayViews(isHidden: Bool) {
        chartManagerUI?.tooltipView.isHidden = isHidden
        chartManagerUI?.percentChange.isHidden = isHidden
        chartManagerUI?.rightClickMenu.isHidden = !isHidden
    }
    
    private func handleViewsVisibilityOnFailure(parameters: MouseEventParams) {
        toggleDisplayViews(isHidden: true)
        
        if (chartManagerUI?.rightClickMenu.isHidden)! && !isWasShown {
            chartManagerUI?.rightClickMenu.isHidden = false
        }
        
        if !(chartManagerUI?.rightClickMenu.isHidden)! && isWasShown {
            chartManagerUI?.rightClickMenu.isHidden = true
        }
        
        isWasShown = true
    }
    
    @objc func hideMenu(notification: NSNotification) {
        chartManagerUI?.rightClickMenu.isHidden = true
    }
    
    func didVisibleTimeRangeChange(onChart chart: ChartApi, parameters: TimeRange?) {
    }
    
    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {
    }
}



