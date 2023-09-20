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
    @IBOutlet weak var recieveVolumeText: UITextView!
    let navView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
    lazy var label = UILabel(frame: CGRect(x: 0, y: 0, width: navView.frame.width - 3, height: navView.frame.height))
    let stackView = UIStackView()
    let leftPartView = UILabel()
    let middlePartView = UILabel()
    let rightPartView = UILabel()
    
    var webSocketManagers = [WebSocketManager]()
    var chartManager: ChartManager!
    var candles = [PreviousCandlesModel]()
    var data = [CandlestickData]()
    var currentCandelModel: CurrentCandleModel!
    
//    var symbol: String!
    var price: String!
    var base = ""
    var quote = ""
    var closePrice: Double = 0
    
    // data from MarkPriceStream
    var symbol: String = ""
    var fundingRate: String = "0.0"
    var nextFindingTime: Double = 0.0
    
    var isKlineClose = false
    var alarm: Double = 0
    var isAlertShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2
//        label.text = "\(symbol!)\n\(price!)"
        label.textAlignment = .left
        navView.addSubview(label)
        
        self.navigationItem.titleView = navView

        let setAlarmButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(addAlarm))
        navigationItem.rightBarButtonItems = [setAlarmButton]
                                              
//        updateView(symbol: symbol, price: price)
//        startCandlesManager()
        startChartManager()
//        startWebSocketManagers()
        
        leftPartView.translatesAutoresizingMaskIntoConstraints = false
        leftPartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        leftPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        leftPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        leftPartView.font = .systemFont(ofSize: 13)
        leftPartView.numberOfLines = 2
//        leftPartView.text = "Нива стоит\n\(price!)$"
        leftPartView.textAlignment = .center

        middlePartView.translatesAutoresizingMaskIntoConstraints = false
        middlePartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        middlePartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        middlePartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        middlePartView.font = .systemFont(ofSize: 13)
        middlePartView.numberOfLines = 2
//        middlePartView.text = "Жигули стоят\n\(price!)$"
        middlePartView.textAlignment = .center

        rightPartView.translatesAutoresizingMaskIntoConstraints = false
        rightPartView.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        rightPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        rightPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        rightPartView.font = .systemFont(ofSize: 13)
        rightPartView.numberOfLines = 2
        rightPartView.text = "funding: \(fundingRate)\nnext funding:\(nextFindingTime)"
        rightPartView.textAlignment = .left

        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.spacing = 5.0
        
        stackView.addArrangedSubview(leftPartView)
        stackView.addArrangedSubview(middlePartView)
        stackView.addArrangedSubview(rightPartView)
        
        self.view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        var openPrice = Double(candleModel.openPrice)!
        var lowPrice = Double(candleModel.lowPrice)!
        isKlineClose = candleModel.isKlineClose
        currentCandelModel = candleModel
        
        chartManager.tick()
        alarmObserver()
        label.text = "\(symbol)\n\(closePrice)"
//        leftPartView.text = "Нива стоит\n\(openPrice)$"
//        middlePartView.text = "Жигули стоят\n\(lowPrice)$"
//        rightPartView.text = "Виталя сделал берпи? \(isKlineClose)"
    }
    
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {
        symbol = dataModel.symbol
        let dundingrRateDouble = Double(dataModel.fundingRate)! * 100
        fundingRate = String(format: "%.3f", dundingrRateDouble)
        
//        fundingRate = String(format: "%.3f", dataModel.fundingRate)
        nextFindingTime = dataModel.nextFindingTime
        
        rightPartView.text = "funding: \(fundingRate)\nnext funding:\(nextFindingTime)"
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
}

