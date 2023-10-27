//
//  CandleStickDataManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 27.10.2023.
//

import Foundation
import LightweightCharts


enum NetworkError: Error {
   case badUrl, badResponse, badData
}

class CandleStickDataManager {
    let binanceURL = "https://fapi.binance.com"
    var delegate: DetailViewController!

    func fetchCandles(from symbol: String, timeFrame: String, completion: @escaping (Result<[[Any]], NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: binanceURL)
        urlComponents?.path = "/fapi/v1/continuousKlines"
        urlComponents?.queryItems = [
            URLQueryItem(name: "pair", value: symbol),
            URLQueryItem(name: "contractType", value: "PERPETUAL"),
            URLQueryItem(name: "interval", value: timeFrame)
        ]

        guard let url = urlComponents?.url else {
            completion(.failure(.badUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(.badResponse))
                return
            }
            guard let safeData = data else {
                completion(.failure(.badData))
                return
            }
            
            do {
                let decodedData = try JSONSerialization.jsonObject(with: safeData, options: []) as? [[Any]]
                guard let marketData = decodedData else {
                    throw NetworkError.badData
                }
                completion(.success(marketData))
            }
            catch {
                completion(.failure(.badData))
            }
        }
        task.resume()
    }

    func parseJSON(marketData: [[Any]]) -> [CandlestickData]  {
        var candles = [CandlestickData]()
        for i in 0..<marketData.count {
            let openPrice = marketData[i][1] as! String
            let highPrice = marketData[i][2] as! String
            let lowPrice = marketData[i][3] as! String
            let closePrice = marketData[i][4] as! String
            
            let candle = CandlestickData(time: .utc(timestamp: (marketData[i][0] as! Double) / 1000),
                                         open: (Double(openPrice)),
                                         high: (Double(highPrice)),
                                         low: (Double(lowPrice)),
                                         close: (Double(closePrice)))
            candles.append(candle)
        }
        return candles
    }
}


// старые методы из чарт менеджера
//func fetchRequest(symbol: String, timeFrame: String) {
//    let path = "/fapi/v1/continuousKlines?pair=\(symbol)&contractType=PERPETUAL&interval=\(timeFrame)"
//    let urlString = binanceURL + path
//    print(urlString)
//    performRequest(urlString: urlString)
//}
//
//func performRequest(urlString: String)  {
//    if let url = URL(string: urlString) {
//        let session = URLSession(configuration: .default)
//        let task = session.dataTask(with: url) { [self] (data, response, error) in
//            if error != nil {
//                print(error!)
//                return
//            }
//            if let safeData = data {
//                parseJSON(marketData: safeData)
//
//            }
//        }
//        task.resume()
//    }
//}
//
//func parseJSON(marketData: Data)  {
//    do {
//        if let decodedData = try JSONSerialization.jsonObject(with: marketData, options: []) as? [[Any]] {
//            for i in 0..<decodedData.count {
//                let openPrice = decodedData[i][1] as! String
//                let highPrice = decodedData[i][2] as! String
//                let lowPrice = decodedData[i][3] as! String
//                let closePrice = decodedData[i][4] as! String
//
//                let candle = CandlestickData(time: .utc(timestamp: (decodedData[i][0] as! Double) / 1000),
//                                             open: (Double(openPrice)),
//                                             high: (Double(highPrice)),
//                                             low: (Double(lowPrice)),
//                                             close: (Double(closePrice)))
//                data.append(candle)
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                self?.setupSeries()
//                if self?.data[0].close == nil {
//                    print("Не удалось загрузить данные data[0].close.")
//                } else {
//                    if (self?.data[0].close)! < 1 {
//                        self?.numberAfterDecimalPoint = "4"
//                    }
//                }
//            }
//
//            delegate.startWebSocketManagers()
//        } else {
//            print("Ошибка приведения типа")
//        }
//    } catch let error as NSError {
//        print("Failed to load: \(error.localizedDescription)")
//    }
//
//}

