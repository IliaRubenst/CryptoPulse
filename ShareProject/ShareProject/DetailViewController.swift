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
    var webSocketManager = WebSocketManager()
    var chartManager = ChartManager()
    
    var candles = [PreviousCandlesModel]()
    
    var symbol: String!
    var price: String!
    var base = ""
    var quote = ""
    var openPrice: Double = 0
    var highPrice: Double = 0
    var lowPrice: Double = 0
    var closePrice: Double = 0
    var isKlineClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView(symbol: symbol, price: price)
        startWebSocketManagers()
        startChartManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for manager in webSocketManagers {
            manager.close()
        }
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
    }
    
    func startChartManager() {
        chartManager.delegate = self
        chartManager.setupChart()
        chartManager.setupSeries()
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
}

