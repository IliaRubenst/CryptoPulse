//
//  WebSocketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit


//class WebSocketManager: DetailViewController, URLSessionWebSocketDelegate {
//    private var webSocket: URLSessionWebSocketTask?
//
//    var isClose = false
//    @objc func webSocketConnect() {
//        isClose = false
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
//        
//        let coinSymbol = "btcusdt@aggTrade"
//        guard let url = URL(string: "wss://stream.binance.com:443/ws/\(coinSymbol)") else { return }
//        print(url)
//        webSocket = session.webSocketTask(with: url)
//        webSocket?.resume()
//    }
//    
//    func ping() {
//        webSocket?.sendPing { error in
//            if let error = error {
//                print("Ping error: \(error)")
//            }
//        }
//    }
//    
//    @objc func close() {
//        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
//        isClose = true
//    }
//    
//    func send() {
//        if !isClose {
//            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//                self.send()
//                self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
//                    if let error = error {
//                        print("Send error: \(error)")
//                    }
//                })
//            }
//        }
//    }
//    
//    func recieve() {
//        webSocket?.receive(completionHandler: { [weak self] result in
//            switch result {
//            case .success(let message):
//                switch message {
//                case .data(let data):
//                    print("Got data: \(data)")
//                case .string(let message):
//                    print("Got string: \(message)")
//                @unknown default:
//                    break
//                }
//            case .failure(let error):
//                print("Receive error: \(error)")
//            }
//            
//            self?.recieve()
//        })
//    }
//    
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//        print("Did connect to socket")
//        ping()
//        recieve()
//        send()
//    }
//    
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//        print("Did close connection with reason")
//    }
//}

