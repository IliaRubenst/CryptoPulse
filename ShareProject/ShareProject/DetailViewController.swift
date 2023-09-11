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
    
    var webSocketManager = WebSocketManager()
    
    var symbol: String!
    var price: String!

    var isClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView(symbol: symbol, price: price)
        webSocketManager.webSocketConnect(symbol: symbol)
        
        webSocketManager.onValueChanged = { price, symbol in
            self.updateView(symbol: symbol, price: price)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webSocketManager.close()
    }
    
    func updateView(symbol: String, price: String) {
        if let doublePrice = Double(price) {
            receiveDataText.text = String(format: "Current price of \(symbol)\n is %.6f", doublePrice)
        }
    }
}
