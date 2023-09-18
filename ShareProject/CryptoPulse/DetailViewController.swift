//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit
import Foundation
import LightweightCharts

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        return Set(self).isSubset(of: nums)
    }
}

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
    var closePrice: Double = 0
    var isKlineClose = false
    var alarm: Double = 0
    var isAlertShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem = backBarButtonItem
        
        navigationItem.backButtonTitle = ""
        let setAlarmButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(addAlarm))
        navigationItem.rightBarButtonItems = [setAlarmButton]
        
//        let coinInfo = UILabel()
//        coinInfo.text = "\(symbol ?? "error")\n\(closePrice)"
//        let button = UIBarButtonItem(customView: coinInfo)
//        
                                              
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
            receiveDataText.text = String(format: "\(symbol)\n%.6f$", doublePrice)
        }
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        closePrice = Double(candleModel.closePrice)!
        isKlineClose = candleModel.isKlineClose
        
        chartManager.tick()
        alarmObserver()
    }
    
    
    func alarmObserver() {
        let upToDown = "пересекла сверху вниз"
        let downToUp = "пересекла снизу вверх"
        for (index, state) in AlarmModelsArray.alarms.enumerated() where state.isActive {
            if state.isAlarmUpper {
                if closePrice >= state.alarmPrice && !isAlertShowing {
                    let ac = UIAlertController(title: "Alarm for \(state.symbol)", message: "The price crossed \(state.alarmPrice) \(downToUp) ", preferredStyle: .alert)
                    isAlertShowing = true
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.isAlertShowing = false
                    })
                    present(ac, animated: true)
                    
                    chartManager.removeAlarmLine(index)
                    AlarmModelsArray.alarms.remove(at: index)
                }
            } else {
                if closePrice <= state.alarmPrice && !isAlertShowing {
                    let ac = UIAlertController(title: "Alarm for \(state.symbol)", message: "The price crossed \(state.alarmPrice) \(upToDown) ", preferredStyle: .alert)
                    isAlertShowing = true
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.isAlertShowing = false
                    })
                    present(ac, animated: true)
                    chartManager.removeAlarmLine(index)
                    AlarmModelsArray.alarms.remove(at: index)
                }
            }
        }
    }
    
    func startChartManager() {
        chartManager.delegate = self
        chartManager.setupChart()
        chartManager.setupSeries()
        chartManager.setupSubscription()
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
//            case .aggTrade:
//                manager.onPriceChanged = { price, symbol in
//                    self.updateView(symbol: symbol, price: price)
//                }
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
            print(webSocketManagers)
        }
    }
    
    @objc func addAlarm() {
        let ac = UIAlertController(title: "Set alarm for \(symbol!)", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "00.00"
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        ac.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            if text != "" && text.isNumeric {
                self!.alarm = Double(text)!
                var isAlarmUpper = false
                if self!.alarm > self!.closePrice {
                    isAlarmUpper = true
                }
                AlarmModelsArray.alarms.append(AlarmModel(symbol: self!.symbol, alarmPrice: self!.alarm, isAlarmUpper: isAlarmUpper, isActive: true))
                self?.chartManager.setupAlarmLine(self!.alarm)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

