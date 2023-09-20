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
    
    var pair: String
    var interval: String
    let binanceURL = "https://fapi.binance.com"
    
    private var chart: LightweightCharts!
    private var series: CandlestickSeries!
    private var alarmLine: PriceLine!
    
//    var openPrice: Double = 0
//    var highPrice: Double = 0
//    var lowPrice: Double = 0
//    var closePrice: Double = 0
//    var isKlineClose = false
    var isFirstKline = true
    
    var data = [CandlestickData]()
    
//    private lazy var lastClose = data.last!.close
//    private lazy var targetPrice = closePrice
    private var currentBusinessDay = Date().timeIntervalSince1970 //BusinessDay(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()))
    lazy var currentBar = CandlestickData(time: .utc(timestamp: currentBusinessDay), open: nil, high: nil, low: nil, close: nil)
    
    private let tooltipView = TooltipView(accentColor: UIColor(red: 0, green: 150/255.0, blue: 136/255.0, alpha: 1))
   
    init(delegate: DetailViewController, pair: String, interval: String) {
        self.delegate = delegate
        self.pair = pair
        self.interval = interval
    }
    
    func fetchRequest() {
        let path = "/fapi/v1/continuousKlines?pair=\(pair)&contractType=PERPETUAL&interval=\(interval)"
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
//                    let candle = PreviousCandlesModel(openTime: decodedData[i][0] as! Double,
//                                                      openPrice: decodedData[i][1] as! String,
//                                                      highPrice: decodedData[i][2] as! String,
//                                                      lowPrice: decodedData[i][3] as! String,
//                                                      closePrice: decodedData[i][4] as! String,
//                                                      volume: decodedData[i][5] as! String,
//                                                      closeTime: decodedData[i][6] as! Int,
//                                                      quoteAssetVolume: decodedData[i][7] as! String,
//                                                      numberOfTrades: decodedData[i][8] as! Int,
//                                                      takerBuyVolume: decodedData[i][9] as! String,
//                                                      takerBuyQuoteAssetVolume: decodedData[i][10] as! String)
//                    delegate.candles.append(candle)
                    let openPrice = decodedData[i][1] as! String
                    let highPrice = decodedData[i][2] as! String
                    let lowPrice = decodedData[i][3] as! String
                    let closePrice = decodedData[i][4] as! String

                    let candle = CandlestickData(time: .utc(timestamp: (decodedData[i][0] as! Double) / 1000),
                                                 open: (Double(openPrice)),
                                                 high: (Double(highPrice)),
                                                 low: (Double(lowPrice)),
                                                 close: (Double(closePrice)))
//                    delegate.chartManager.data.append(candle)
                    data.append(candle)
                }
                print("Loaded \(data.count) candles")
//                setupChart()
                
                DispatchQueue.main.async {
                    self.setupSeries()
                }
                
                delegate.startWebSocketManagers()
            } else {
                print("Ошибка приведения типа")
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    
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
        
        delegate.view.addSubview(tooltipView)
        
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tooltipView.leadingAnchor.constraint(equalTo: delegate.view.safeAreaLayoutGuide.leadingAnchor),
            tooltipView.trailingAnchor.constraint(equalTo: delegate.view.safeAreaLayoutGuide.trailingAnchor),
            tooltipView.topAnchor.constraint(equalTo: delegate.recieveVolumeText.bottomAnchor),
        ])

        
        tooltipView.isHidden = true
        
        delegate.view.bringSubviewToFront(tooltipView)
    }
    
    func setupSeries() {
        let series = chart.addCandlestickSeries(options: nil)
        self.series = series
        
        // Здесь точка синхрнизации. Ждет, пока не загрузит массив свечек. Решение, наверное, так себе, но с GCD я пока хз как завести. Периодически вызывает краш приложения.
//        while delegate.candles.count != 500 {
//            continue
//        }
//        delegate.updateData()
        data.removeLast()
        
        series.setData(data: data)
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
            if let nextMinute = nextMinute(currentBusinessDay) {
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
    
    func nextMinute(_ time: TimeInterval) -> TimeInterval? {
        let date = Date(timeIntervalSince1970: time)
        var dateComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
        dateComponents.minute! += 1
        guard let timeInterval = Calendar.current.date(from: dateComponents)?.timeIntervalSince1970 else {
            print("Error in nextMinute methode, can't get TimeInterval")
            return nil
        }
        return timeInterval
        
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
    
    
func setupAlarmLine(_ alarmPrice: Double) {
        let options = PriceLineOptions(
            price: alarmPrice,
            color: "#f00",
            lineWidth: .one,
            lineStyle: .solid
        )
        
        alarmLine = series.createPriceLine(options: options)
        AlarmModelsArray.alarmaLine.append(alarmLine)
    }
    
    func removeAlarmLine(_ index: Int) {
        series.removePriceLine(line: AlarmModelsArray.alarmaLine[index])
        AlarmModelsArray.alarmaLine.remove(at: index)
    }
    
    func setupSubscription() {
        chart.delegate = self
        chart.subscribeCrosshairMove()
    }
    
}

extension ChartManager: ChartDelegate {
    
    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {
    }
    
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        if case .utc(timestamp: _) = parameters.time,
           case let .barData(data) = parameters.price(forSeries: series) {
            tooltipView.update(title: "o:\(data.open!), h:\(data.high!), l:\(data.low!), c:\(data.close!)")
            tooltipView.isHidden = false
        } else {
            self.tooltipView.isHidden = true
        }
    }
    
    func didVisibleTimeRangeChange(onChart chart: ChartApi, parameters: TimeRange?) {
        
    }
}


//    func reset() {
//        series.setData(data: data)
        
//        lastClose = data.last!.close
//        lastIndex = data.endIndex - 1
//
//        targetIndex = lastIndex + 5 + Int((Double.random(in: 0...1) + 30).rounded())
////        targetPrice = closePrice
        
//        currentIndex = lastIndex + 1
//        currentBusinessDay = BusinessDay(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()))
//        ticksInCurrentBar = 0
//    }
