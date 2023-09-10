//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit

class DetailViewController: UIViewController, URLSessionWebSocketDelegate {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var receiveDataText: UITextView!
    
    var symbol: String!
    var price: String!
    
    var objectSymbol = "name"
    var objectPrice = "0.0$"
    
    private var webSocket: URLSessionWebSocketTask?
    var isClose = false
    var receivedData: String? {
        didSet {
            receiveDataText.text = "Current price of \(objectSymbol) \n is \(objectPrice) $"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveDataText.text = "Current price of name \n is    $"
//        symbolLabel.text = "Current coin is \(ReceivedWebData.s) price \(ReceivedWebData.p) $"
        webSocketConnect()
        let startConnectionBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(webSocketConnect))
        let stopConnectionBtn = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(close))
        navigationItem.rightBarButtonItems = [startConnectionBtn, stopConnectionBtn]
    }
    
    @objc func webSocketConnect() {
        isClose = false
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)

//        let coinSymbol = "ethusdt"
        let coinSymbol = symbol.lowercased()
        guard let url = URL(string: "wss://fstream.binance.com:443/ws/\(coinSymbol)@aggTrade") else { return }
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
//        print(url)
//        print(coinSymbol)
//        print(symbol.lowercased())
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
        isClose = true
    }
    
    func send() {
//        if !isClose {
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//                self.send()
//                self.webSocket?.send(.string("Send new request"), completionHandler: { error in
//                    if let error = error {
//                        print("Send error: \(error)")
//                    }
//                })
//            }
//        }
    }
    
    func recieve() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
//                    print("Got string: \(message)")
                    self?.receivedData = message
                    self?.parseJSONWeb(socketString: message)
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            
            self?.recieve()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        recieve()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }
    
    func parseJSONWeb(socketString: String) {
        guard let socketData = socketString.data(using: String.Encoding.utf8) else { return }
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ReceivedSocketData.self, from: socketData)
            objectSymbol = decodedData.s
            objectPrice = decodedData.p
            print(objectPrice)
        } catch {
            print("Error JSON: \(error)")
        }
    }
}
