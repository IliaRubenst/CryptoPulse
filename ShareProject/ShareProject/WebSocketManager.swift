//
//  WebSocketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit
// wss://fstream.binance.com/stream?streams=bnbusdt@aggTrade/btcusdt@markPrice

protocol WebSocketManagerDelegate {
    func didUpdateCandle(_ websocketManager: WebSocketManager, coinModel: CoinModel)
    
}

enum State: CaseIterable {
    case aggTrade
    case ticker
}

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    
    var delegate: WebSocketManagerDelegate!
    
    var onPriceChanged: ((String, String) -> ())?
    var onVolumeChanged: ((String, String) -> ())?
    var onCoinModel: ((String, String, String, String) -> ())?
    
    var coinModel: CoinModel? {
        didSet {
            onCoinModel?(coinModel!.closePrice, coinModel!.highPrice, coinModel!.lowPrice, coinModel!.openPrice)
        }
    }
    
    var baseVolume = ""
    var quoteVolume = "" {
        didSet {
            onVolumeChanged?(baseVolume, quoteVolume)
        }
    }
    var objectSymbol = ""
    var objectPrice = "" {
        didSet {
            onPriceChanged?(objectPrice, objectSymbol)
        }
    }
    var openPrice = ""
    var highPrice = ""
    var lowPrice = ""
    var closePrice = ""
    
    var actualState = State.aggTrade
    
    func webSocketConnect(symbol: String) {
        var url: String
        let coinSymbol = symbol.lowercased()
        
        switch actualState {
        case .aggTrade:
            url = "wss://stream.binance.com:443/ws/\(coinSymbol)@aggTrade"
            
        case .ticker:
            url = "wss://stream.binance.com:443/ws/\(coinSymbol)@ticker"
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        
        guard let url = URL(string: url) else { return }
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
                    if let state = self?.actualState {
                        self?.parseJSONWeb(socketString: message, state: state)
                    }
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
    
    func parseJSONWeb(socketString: String, state: State) -> CoinModel? {
        guard let socketData = socketString.data(using: String.Encoding.utf8) else { return nil }
            let decoder = JSONDecoder()
            switch state {
            case .aggTrade:
                do {
                    let decodedData = try decoder.decode(SymbolPriceData.self, from: socketData)
                    objectSymbol = decodedData.s
                    objectPrice = decodedData.p
                    //                print("Тикер: \(objectSymbol), Цена: \(objectPrice)")
                    
                    return nil
                } catch {
                    print("Error JSON: \(error)")
                    
                    return nil
                }
            case .ticker:
                do {
                    let decodedData = try decoder.decode(VolumeData.self, from: socketData)
                    //              сделать получение данных через структуру
                    let currentStreamData = CoinModel(closePrice: decodedData.c, openPrice: decodedData.o, highPrice: decodedData.h, lowPrice: decodedData.l)
                    baseVolume = decodedData.v
                    quoteVolume = decodedData.q
                    
                    //                print("Объем в битках:\(baseVolume), Объем в USDT?: \(quoteVolume)")
                    
//                    print(currentStreamData)
                    delegate.didUpdateCandle(self, coinModel: currentStreamData)
                    return currentStreamData
                } catch {
                    print("Error JSON: \(error)")
                    
                    return nil
                }
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

