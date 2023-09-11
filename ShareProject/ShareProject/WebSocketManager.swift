//
//  WebSocketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit


class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    
    var onValueChanged: ((String, String) -> ())?
    
    var objectSymbol = ""
    var objectPrice = "" {
        didSet {
            onValueChanged?(objectPrice, objectSymbol)
        }
    }
    
    func webSocketConnect(symbol: String) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let coinSymbol = symbol.lowercased()
        guard let url = URL(string: "wss://stream.binance.com:443/ws/\(coinSymbol)@aggTrade") else { return }
        print(url)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        }
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
   
    func recieve() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
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
        } catch {
            print("Error JSON: \(error)")
        }
    }
    
    func send() {
        /*if !isClose {
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self.send()
                self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                    if let error = error {
                        print("Send error: \(error)")
                    }
                })
            }
        }*/
    }
}

