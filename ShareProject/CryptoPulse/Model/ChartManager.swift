//
//  ChartManager.swift
//  ShareProject
//
//  Created by Vitaly on 13.09.2023.
//

import Foundation
import LightweightCharts

class ChartManager {
    var delegate: DetailViewController!
    var alarmManager: AlarmManager!
    
    var symbol: String
    var timeFrame: String
    var isFirstKline = true
    let binanceURL = "https://fapi.binance.com"
    var numberAfterDecimalPoint: String = "2" {
        didSet {
            updateFormat()
        }
    }
    
    private var chart: LightweightCharts!
    var series: CandlestickSeries!
    
    // for rightClickMenu
    private var leadingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    private var bottomConstraintForPercent: NSLayoutConstraint!
    
    var isWasShown = true
    var horizontalLine: CrosshairLineOptions?
    var options: PriceLineOptions!
    var currentCursorPrice: Double!
    
    var data = [CandlestickData]()
    
    private var currentBusinessDay = Date().timeIntervalSince1970
    lazy var currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
    
    private let tooltipView = TooltipView(accentColor: UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1))
    private let perecentChange = PercentChange(color: UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1))
    private let rightClickMenu = RightClickMenu(color: UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1))
    let alarmIndicator = AlarmIndicator(color: UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1))
    
    
    init(delegate: DetailViewController, symbol: String, timeFrame: String) {
        self.delegate = delegate
        self.symbol = symbol
        self.timeFrame = timeFrame
    }
    
    func fetchRequest(symbol: String, timeFrame: String) {
        let path = "/fapi/v1/continuousKlines?pair=\(symbol)&contractType=PERPETUAL&interval=\(timeFrame)"
        let urlString = binanceURL + path
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String)  {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { [self] (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    parseJSON(marketData: safeData)
                    
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(marketData: Data)  {
        do {
            if let decodedData = try JSONSerialization.jsonObject(with: marketData, options: []) as? [[Any]] {
                for i in 0..<decodedData.count {
                    let openPrice = decodedData[i][1] as! String
                    let highPrice = decodedData[i][2] as! String
                    let lowPrice = decodedData[i][3] as! String
                    let closePrice = decodedData[i][4] as! String
                    
                    let candle = CandlestickData(time: .utc(timestamp: (decodedData[i][0] as! Double) / 1000),
                                                 open: (Double(openPrice)),
                                                 high: (Double(highPrice)),
                                                 low: (Double(lowPrice)),
                                                 close: (Double(closePrice)))
                    data.append(candle)
                }
                
                DispatchQueue.main.async { [self] in
                    self.setupSeries()
                    
                    if data[0].close! < 1{
                        numberAfterDecimalPoint = "4"
                    }
                }
                
                delegate.startWebSocketManagers()
            } else {
                print("Ошибка приведения типа")
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func updateFormat() {
        chart.applyOptions(options: ChartOptions(localization: LocalizationOptions(priceFormatter: .javaScript("function(price) { return '$' + price.toFixed(\(numberAfterDecimalPoint)); }"))))
    }
    
    
    func setupChart() {
        
        let options = ChartOptions(timeScale: TimeScaleOptions(borderVisible: true,
                                                               timeVisible: true,
                                                               secondsVisible: true,
                                                               ticksVisible: true),
                                   crosshair: CrosshairOptions(mode: .normal),
                                   localization: LocalizationOptions(priceFormatter: .javaScript("function(price) { return '$' + price.toFixed(\(numberAfterDecimalPoint)); }")),
                                   trackingMode: TrackingModeOptions(exitMode: .onTouchEnd))

        
        let chart = LightweightCharts(options: options)
        
        alarmManager = AlarmManager(detailViewController: delegate, chartManager: self)
        alarmManager?.setupAlarmLines()
        
        delegate.lightWeightChartView.addSubview(chart)
        
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: delegate.lightWeightChartView.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: delegate.lightWeightChartView.trailingAnchor),
            chart.topAnchor.constraint(equalTo: delegate.lightWeightChartView.topAnchor),
            chart.bottomAnchor.constraint(equalTo: delegate.lightWeightChartView.bottomAnchor)
        ])
        
        self.chart = chart
        
        delegate.lightWeightChartView.addSubview(tooltipView)
        
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tooltipView.leadingAnchor.constraint(equalTo: chart.leadingAnchor),
            tooltipView.trailingAnchor.constraint(equalTo: chart.trailingAnchor),
            tooltipView.topAnchor.constraint(equalTo: chart.topAnchor),
            tooltipView.bottomAnchor.constraint(equalTo: chart.bottomAnchor)
        ])
        
        tooltipView.isHidden = true

        delegate.lightWeightChartView.addSubview(rightClickMenu)
        rightClickMenu.isHidden = true

        rightClickMenu.translatesAutoresizingMaskIntoConstraints = false
        
        leadingConstraint = rightClickMenu.leadingAnchor.constraint(equalTo: chart.leadingAnchor)
        bottomConstraint = rightClickMenu.bottomAnchor.constraint(equalTo: chart.topAnchor)
        leadingConstraint.isActive = true
        bottomConstraint.isActive = true
        rightClickMenu.widthAnchor.constraint(equalToConstant: 63).isActive = true
        rightClickMenu.heightAnchor.constraint(equalToConstant: 30).isActive = true

//        delegate.lightWeightChartView.addSubview(alarmIndicator)
//
//        alarmIndicator.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            alarmIndicator.leadingAnchor.constraint(equalTo: chart.leadingAnchor, constant: 30),
//            alarmIndicator.widthAnchor.constraint(equalToConstant: 20),
//            alarmIndicator.heightAnchor.constraint(equalToConstant: 20)
//        ])
//
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragTheView))
//        alarmIndicator.addGestureRecognizer(panGestureRecognizer)
        
        delegate.lightWeightChartView.addSubview(perecentChange)
        perecentChange.isHidden = tooltipView.isHidden
        perecentChange.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraintForPercent = perecentChange.bottomAnchor.constraint(equalTo: chart.topAnchor)
        bottomConstraintForPercent.isActive = true
        
        delegate.lightWeightChartView.bringSubviewToFront(tooltipView)
        delegate.lightWeightChartView.bringSubviewToFront(rightClickMenu)
//        delegate.lightWeightChartView.bringSubviewToFront(alarmIndicator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenu), name: NSNotification.Name(rawValue: "anyBtnPressed"), object: nil)
    }
    
    @objc func dragTheView(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            
        } else if recognizer.state == .changed {
            let translation = recognizer.translation(in: self.chart)
            
//            let newX = alarmIndicator.center.x + translation.x
            let newY = alarmIndicator.center.y + translation.y
            
            alarmIndicator.center = CGPoint(x: 40, y: newY)
            recognizer.setTranslation(CGPoint.zero, in: self.chart)
            
        } else if recognizer.state == .ended {
            
        }
    }
    
    func setupSeries() {
        let series = chart.addCandlestickSeries(options: nil)
        self.series = series
        data.removeLast()
        series.setData(data: data)
        alarmManager.setupAlarmLines()
    }
    
    func tick() {
        if isFirstKline {
            guard let open = Double(delegate.currentCandelModel.openPrice),
                  let high = Double(delegate.currentCandelModel.highPrice),
                  let low = Double(delegate.currentCandelModel.lowPrice),
                  let close = Double(delegate.currentCandelModel.openPrice) else { return }
            
            currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: open, high: high, low: low, close: close)
            
            isFirstKline = false
        }
        
        if delegate.isKlineClose {
            if let nextMinute = nextCandle(currentBusinessDay) {
                currentBusinessDay = nextMinute
                currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
            }
        }
        
        mergeTickToBar(delegate.closePrice) //Вот этот момент я бы поправил, беря данные из обновляемой модели, а не из конкретной переменной, которая загружается из didUpdateCandle.
    }
    
    func mergeTickToBar(_ price: BarPrice) {
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
        series.update(bar: currentBar)
    }
    
    func nextCandle(_ time: TimeInterval) -> TimeInterval? {
        let date = Date(timeIntervalSince1970: time)
        var dateComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
        dateComponents.minute! += 1
        guard let timeInterval = Calendar.current.date(from: dateComponents)?.timeIntervalSince1970 else {
            print("Error in nextMinute methode, can't get TimeInterval")
            return nil
        }
        return timeInterval
        
    }
    
    func setupSubscription() {
        chart.delegate = self
        chart.subscribeCrosshairMove()
    }
}

extension ChartManager: ChartDelegate {
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        guard case .utc(timestamp: _) = parameters.time,
              let point = parameters.point,
              case let .barData(data) = parameters.price(forSeries: series),
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
        tooltipView.update(title: "o:\(open), h:\(high), l:\(low), c:\(close)")
        bottomConstraintForPercent.constant = CGFloat(point.y) - 17
        leadingConstraint.constant = CGFloat(point.x) + 5
        bottomConstraint.constant = CGFloat(point.y) + 5
        isWasShown = false
    }

    private func updateCurrentCursorPrice(from coordinate: Double) {
        series.coordinateToPrice(coordinate: coordinate) { [self] price in
            guard let price = price else { return }
            currentCursorPrice = price
            let percentChange = ((price * 100) / delegate.closePrice - 100)
            perecentChange.update(title: String(format: "%.2f%", percentChange))
        }
        rightClickMenu.isHidden = true
    }

    private func toggleDisplayViews(isHidden: Bool) {
        tooltipView.isHidden = isHidden
        perecentChange.isHidden = isHidden
        rightClickMenu.isHidden = !isHidden
    }
    
    private func handleViewsVisibilityOnFailure(parameters: MouseEventParams) {
        toggleDisplayViews(isHidden: true)
        
        if rightClickMenu.isHidden && !isWasShown {
            rightClickMenu.isHidden = false
        }
        
        if !rightClickMenu.isHidden && isWasShown {
            rightClickMenu.isHidden = true
        }
        
        isWasShown = true
    }

    @objc func hideMenu(notification: NSNotification) {
        rightClickMenu.isHidden = true
    }
    
    func didVisibleTimeRangeChange(onChart chart: ChartApi, parameters: TimeRange?) {
    }
    
    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {
    }
}



