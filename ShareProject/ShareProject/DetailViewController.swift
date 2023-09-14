//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit
import LightweightCharts

class DetailViewController: UIViewController, WebSocketManagerDelegate {
    @IBOutlet weak var receiveDataText: UITextView!
    @IBOutlet weak var recieveVolumeText: UITextView!
    
    var webSocketManagers = [WebSocketManager]()
    var chartManager = ChartManager()
    
    var candles = [PreviousCandlesModel]()
    var data = [CandlestickData]()    
    
    var symbol: String!
    var price: String!
    var base = ""
    var quote = ""
    var openPrice: Double = 0
    var highPrice: Double = 0
    var lowPrice: Double = 0
    var closePrice: Double = 0
    var isKlineClose = false
    var alarm: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(updateData))
        updateView(symbol: symbol, price: price)
        startCandlesManager()
        startChartManager()
        startWebSocketManagers()
    }
    
    // Вынести метод в модель chartManager. Заленился.
    @objc func updateData() {
       for i in 0..<candles.count {
            let doubleOpenTime = Double(candles[i].openTime)
            
            let newCandle = CandlestickData(time: .utc(timestamp: doubleOpenTime / 1000), open: Double(candles[i].openPrice), high: Double(candles[i].highPrice), low: Double(candles[i].lowPrice), close: Double(candles[i].closePrice))
            chartManager.data.append(newCandle)
            
            /*chartManager.data[i].time = .utc(timestamp: doubleOpenTime / 1000)
            chartManager.data[i].open = Double(candles[i].openPrice)
            chartManager.data[i].high = Double(candles[i].highPrice)
            chartManager.data[i].low = Double(candles[i].lowPrice)
            chartManager.data[i].close = Double(candles[i].closePrice)*/
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for manager in webSocketManagers {
            manager.close()
        }
        candles.removeAll()
        chartManager.data.removeAll()
    }
    
    func updateView(symbol: String, price: String) {
        if let doublePrice = Double(price) {
            receiveDataText.text = String(format: "Current price of \(symbol)\n is %.6f$", doublePrice)
        }
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        closePrice = Double(candleModel.closePrice)!
        openPrice = Double(candleModel.openPrice)!
        highPrice = Double(candleModel.highPrice)!
        lowPrice = Double(candleModel.lowPrice)!
        isKlineClose = candleModel.isKlineClose
        
        
        let noisedPrice = closePrice
        
        chartManager.mergeTickToBar(noisedPrice)
        
        if isKlineClose {
            chartManager.tick()
        }
//        alarmObserver()
    }
    
    
    /*func alarmObserver() {
        let upToDown = "пересекла сверху вниз"
        let downToUp = "пересекла снизу вверх"
//        let check = (closePrice > alarm) ? (closePrice - alarm) : (alarm - closePrice)
                        
        print("alarm \(alarm)")
        print("price \(closePrice)")

        
        var check = AlarmModelsArray.alarms
        print(AlarmModelsArray.alarms)
        for (index, state) in check.enumerated() where state.isActive {
            if state.isUpper {
                if closePrice >= alarm {
//                    state.isActive.toggle()
                    let ac = UIAlertController(title: "Alarm for \(symbol)", message: "The price crossed \(alarm) \(upToDown) ", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Apply", style: .default))
                    present(ac, animated: true)
                    check.remove(at: index)
                }
            } else {
                if closePrice <= alarm {
                    let ac = UIAlertController(title: "Alarm for \(symbol)", message: "The price crossed \(alarm) \(downToUp) ", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Apply", style: .default))
                    present(ac, animated: true)
                    check.remove(at: index)
                }
            }
        }
    }*/
    
    func startChartManager() {
        chartManager.delegate = self
        chartManager.setupChart()
        chartManager.setupSeries()
    }
    
    func startCandlesManager() {
        var candlesManager = PreviousCandlesManager(pair: symbol, interval: "1m")
        candlesManager.delegate = self
        candlesManager.fetchRequest()
    }
    
    func startWebSocketManagers() {
        for state in State.allCases {
            
            let manager = WebSocketManager()
            manager.delegate = self
            manager.actualState = state
            manager.webSocketConnect(symbol: symbol)
            
            switch state {
            case .aggTrade:
                manager.onPriceChanged = { price, symbol in
                    self.updateView(symbol: symbol, price: price)
                }
            case .ticker:
                manager.onVolumeChanged = { base, quote in
                    if let quote = Double(quote) {
                        if let base = Double(base) {
                            self.recieveVolumeText.text = String(format: "Base Volume: \(base.rounded())\nUSDT Volume: %.2f$", quote)
                            
                        }
                    }
                }
            case .currentCandleData:
                print("")
            }
            webSocketManagers.append(manager)
        }
    }
    
    /*@objc func addAlarm() {
        let ac = UIAlertController(title: "Set alarm for \(symbol)", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            self!.alarm = Double(text)!
            var isAlarmUpper = false
            if self!.alarm > self!.closePrice {
                isAlarmUpper = true
            }
            AlarmModelsArray.alarms.append(AlarmModel(symbol: self!.symbol, alarmPrice: self!.alarm, isUpper: isAlarmUpper, isActive: true))
            
//            print(AlarmModelsArray.alarms)
        })
        present(ac, animated: true)
    }*/
}

