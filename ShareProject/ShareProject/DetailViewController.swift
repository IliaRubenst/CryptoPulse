//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var receiveDataText: UITextView!
    @IBOutlet weak var recieveVolumeText: UITextView!
    
    var webSocketManagers = [WebSocketManager]()
    
    var symbol: String!
    var price: String!
    var base = ""
    var quote = ""

    var isClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView(symbol: symbol, price: price)
        startManagers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for manager in webSocketManagers {
            manager.close()
        }
    }
    
    func updateView(symbol: String, price: String) {
        if let doublePrice = Double(price) {
            receiveDataText.text = String(format: "Current price of \(symbol)\n is %.6f", doublePrice)
        }
    }
    
    func startManagers() {
        for state in State.allCases {
            let manager = WebSocketManager()
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
            }
            
            webSocketManagers.append(manager)
        }
    }
}
