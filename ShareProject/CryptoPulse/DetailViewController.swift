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
    let upperStackView = UIStackView()
    let leftNavLabel = UILabel()
    let rightNavLabel = UILabel()
    
    let lowerStackView = UIStackView()
    let leftPartView = UILabel()
    let middlePartView = UILabel()
    let rightPartView = UILabel()
    
    var webSocketManagers = [WebSocketManager]()
    var chartManager: ChartManager!
    var candles = [PreviousCandlesModel]()
    var data = [CandlestickData]()
    var currentCandelModel: CurrentCandleModel!
    
    var price: String = ""
    
    // data from CurrentCandleData
    var closePrice: Double = 0
    
    // data from MarkPriceStream
    var symbol: String = ""
    var fundingRate: String = "0.0"
    var nextFundingTime: String = "00:00:00"
    
    //data from IndividualSymbolTickerStreams
    var priceChangePercent: String = "0.0"
    var volume24h: String = "0.0"
    var maxPrice: String = "0.0"
    var minPrice: String = "0.0"
    
    var isKlineClose = false
    var alarm: Double = 0
    var isAlertShowing: Bool = false
    
    override func loadView() {
        super.loadView()
        
        leftNavLabel.translatesAutoresizingMaskIntoConstraints = false
//        leftNavLabel.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        leftNavLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        leftNavLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        leftNavLabel.font = .systemFont(ofSize: 13)
        leftNavLabel.text = "\(symbol)"
        leftNavLabel.textAlignment = .center
        
        rightNavLabel.translatesAutoresizingMaskIntoConstraints = false
//        rightNavLabel.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        rightNavLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        rightNavLabel.widthAnchor.constraint(equalToConstant: 170).isActive = true
        rightNavLabel.font = .systemFont(ofSize: 13)
        rightNavLabel.numberOfLines = 2
        rightNavLabel.text = "\(closePrice)\n\(priceChangePercent)"
        rightNavLabel.textAlignment = .center
        
        upperStackView.spacing = 5.0
        
        upperStackView.addArrangedSubview(leftNavLabel)
        upperStackView.addArrangedSubview(rightNavLabel)
        
        self.navigationItem.titleView = upperStackView
        
        leftPartView.translatesAutoresizingMaskIntoConstraints = false
//        leftPartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        leftPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        leftPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        leftPartView.font = .systemFont(ofSize: 13)
        leftPartView.numberOfLines = 2
        leftPartView.text = "24h volume\n\(volume24h)"
        leftPartView.textAlignment = .center

        middlePartView.translatesAutoresizingMaskIntoConstraints = false
//        middlePartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        middlePartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        middlePartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        middlePartView.font = .systemFont(ofSize: 13)
        middlePartView.numberOfLines = 2
        middlePartView.text = "max: \(maxPrice)\nmin: \(minPrice)"
        middlePartView.textAlignment = .center

        rightPartView.translatesAutoresizingMaskIntoConstraints = false
//        rightPartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        rightPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        rightPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        rightPartView.font = .systemFont(ofSize: 13)
        rightPartView.numberOfLines = 2
        rightPartView.text = "funding: \(fundingRate)%\nnext:\(nextFundingTime)"
        rightPartView.textAlignment = .center

        lowerStackView.axis = NSLayoutConstraint.Axis.horizontal
        lowerStackView.distribution = .fillEqually
        lowerStackView.alignment = .center
        lowerStackView.backgroundColor = .clear
        lowerStackView.spacing = 5.0
        
        lowerStackView.addArrangedSubview(leftPartView)
        lowerStackView.addArrangedSubview(middlePartView)
        lowerStackView.addArrangedSubview(rightPartView)
        
        self.view.addSubview(lowerStackView)
        
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        lowerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        lowerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        lowerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        lowerStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let setAlarmButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(addAlarm))
        navigationItem.rightBarButtonItems = [setAlarmButton]
        
        startChartManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarm), name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarmForSelectedPrice), name: NSNotification.Name(rawValue: "button2Pressed"), object: nil)
    }
    
    // Вынести метод в модель chartManager. Заленился.
    @objc func updateData() {
       for i in 0..<candles.count {
            let doubleOpenTime = Double(candles[i].openTime)
            
            let newCandle = CandlestickData(time: .utc(timestamp: doubleOpenTime / 1000), open: Double(candles[i].openPrice), high: Double(candles[i].highPrice), low: Double(candles[i].lowPrice), close: Double(candles[i].closePrice))
            chartManager.data.append(newCandle)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for manager in webSocketManagers {
            manager.close()
        }
//        candles.removeAll()
        chartManager.data.removeAll()
    }
    
//    func updateView(symbol: String, price: String) {
//        if let doublePrice = Double(price) {
//            receiveDataText.text = String(format: "\(symbol)\n%.6f$", doublePrice)
//        }
//    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        closePrice = Double(candleModel.closePrice)!
        isKlineClose = candleModel.isKlineClose
        currentCandelModel = candleModel
        
        chartManager.tick()
        alarmObserver()
        rightNavLabel.text = "\(closePrice)\n\(priceChangePercent)%"
    }
    
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {
        symbol = dataModel.symbol
        let dundingrRateDouble = Double(dataModel.fundingRate)! * 100
        fundingRate = String(format: "%.3f", dundingrRateDouble)
        nextFundingTime = dataModel.timeTodateFormat(nextFindingTime: dataModel.nextFundingTime)
        rightPartView.text = "funding: \(fundingRate)%\nnext:\(nextFundingTime)"
    }
    
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {
        priceChangePercent = dataModel.priceChangePercent
        
        maxPrice = dataModel.highPrice
        minPrice = dataModel.lowPrice
        
        let volume = Double(dataModel.volumeQuote)! / 1_000_000
        
        volume24h = String(format: "%.2fm$", volume)
        
        rightNavLabel.text = "\(closePrice)\n\(priceChangePercent)%"
        leftPartView.text = "24h volume\n\(volume24h)"
        middlePartView.text = "max: \(maxPrice)\nmin: \(minPrice)"
    }
    
    
    func alarmObserver() {
        let upToDown = "пересекла сверху вниз"
        let downToUp = "пересекла снизу вверх"
        
        var telegramAlram = TelegramNotifications()
        
        for (index, state) in AlarmModelsArray.alarms.enumerated() where state.isActive {
            if state.isAlarmUpper {
                if closePrice >= state.alarmPrice && !isAlertShowing {
                    telegramAlram.message = "The price crossed \(state.alarmPrice) \(downToUp)"
                    telegramAlram.postRequest()
                    
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
                    telegramAlram.message = "The price crossed \(state.alarmPrice) \(upToDown)"
                    telegramAlram.postRequest()
                    
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
        chartManager = ChartManager(delegate: self, pair: symbol, interval: "1m")
        chartManager.fetchRequest()
        chartManager.setupChart()
        
        chartManager.setupSubscription()
    }
    
//    func startCandlesManager() {
//        var candlesManager = PreviousCandlesManager(pair: symbol, interval: "1m")
//        candlesManager.delegate = self
//        candlesManager.fetchRequest()
//    }
    
    func startWebSocketManagers() {
        for state in State.allCases {
            let manager = WebSocketManager()
            manager.delegate = self
            manager.actualState = state
            manager.webSocketConnect(symbol: symbol)
            
//            switch state {
//            case .markPriceStream:
//                manager.onPriceChanged = { price, symbol in
//                    self.updateView(symbol: symbol, price: price)
//                }
//            case .ticker:
//                manager.onVolumeChanged = { base, quote in
//                    if let quote = Double(quote) {
//                        if let base = Double(base) {
//                            self.recieveVolumeText.text = String(format: "Base Volume: \(base.rounded())\nUSDT Volume: %.2f$", quote)
//                        }
//                    }
//                }
//                _ = 1
//            case .currentCandleData:
//                print("")
//            }
            webSocketManagers.append(manager)
        }
    }
    
    
    // может перенести два метода в AlarmManager?
    @objc func addAlarm() {
        let ac = UIAlertController(title: "Set alarm for \(symbol)", message: nil, preferredStyle: .alert)
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
    
    @objc func addAlarmForSelectedPrice() {
        let price = chartManager.currentBar.high
            alarm = price!
            var isAlarmUpper = false
            if alarm > closePrice {
                isAlarmUpper = true
            }
            AlarmModelsArray.alarms.append(AlarmModel(symbol: symbol, alarmPrice: alarm, isAlarmUpper: isAlarmUpper, isActive: true))
            chartManager.setupAlarmLine(alarm)
    }
}

