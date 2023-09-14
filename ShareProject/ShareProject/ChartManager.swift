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
    
    private var chart: LightweightCharts!
    private var series: CandlestickSeries!
    
    var openPrice: Double = 0
    var highPrice: Double = 0
    var lowPrice: Double = 0
    var closePrice: Double = 0
    var isKlineClose = false
    
    var data = [CandlestickData]()
    
    private lazy var lastClose = data.last!.close
    private lazy var lastIndex = data.endIndex - 1
    private lazy var targetIndex = lastIndex + 105 + Int((Double.random(in: 0...1) + 30).rounded())
//    private lazy var targetPrice = closePrice
    private lazy var currentIndex = lastIndex + 1
    private var ticksInCurrentBar = 0
    private var currentBusinessDay = BusinessDay(year: 2023, month: 9, day: 14)
    private lazy var currentBar = CandlestickData(time: .businessDay(currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
    
    func setupChart() {
        let options = ChartOptions(crosshair: CrosshairOptions(mode: .normal))
        let chart = LightweightCharts(options: options)
        delegate.view.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: delegate.view.safeAreaLayoutGuide.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: delegate.view.safeAreaLayoutGuide.trailingAnchor),
            chart.topAnchor.constraint(equalTo: delegate.recieveVolumeText.bottomAnchor),
            chart.bottomAnchor.constraint(equalTo: delegate.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        self.chart = chart
    }
    
    func setupSeries() {
        let series = chart.addCandlestickSeries(options: nil)
        self.series = series
        
        // Здесь точка синхрнизации. Ждет, пока не загрузит массив свечек. Решение, наверное, так себе, но с GCD я пока хз как завести.
        while delegate.candles.count != 500 {
            continue
        }
        
        delegate.updateData()
        series.setData(data: data)
        tick()
    }

    func tick() {
//        let lastClose = self.lastClose ?? 0
        
        ticksInCurrentBar += 1
        if ticksInCurrentBar == 1 {
            // move to next bar
            currentIndex += 1
            currentBusinessDay = nextBusinessDay(currentBusinessDay)
            currentBar = CandlestickData(time: .businessDay(currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
            ticksInCurrentBar = 0
            if currentIndex == 5000 {
                reset()
                return
            }
            if currentIndex == targetIndex {
                self.lastClose = closePrice
                lastIndex = currentIndex
                targetIndex = lastIndex + 2
//                targetPrice = closePrice
            }
        }
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
    
    func reset() {
        series.setData(data: data)
        
        lastClose = data.last!.close
        lastIndex = data.endIndex - 1
        
        targetIndex = lastIndex + 5 + Int((Double.random(in: 0...1) + 30).rounded())
//        targetPrice = closePrice
        
        currentIndex = lastIndex + 1
        currentBusinessDay = BusinessDay(year: 2023, month: 9, day: 14)
        ticksInCurrentBar = 0
    }
    
    func nextBusinessDay(_ time: BusinessDay) -> BusinessDay {
        let timeZone = TimeZone(identifier: "UTC")!
        let dateComponents = DateComponents(
            calendar: .current,
            timeZone: timeZone,
            year: time.year,
            month: time.month - 1,
            day: time.day + 1
        )
        let date = Calendar.current.date(from: dateComponents)!
        let components = Calendar.current.dateComponents(in: timeZone, from: date)
        return BusinessDay(year: components.year!, month: components.month! + 1, day: components.day!)
    }
}
