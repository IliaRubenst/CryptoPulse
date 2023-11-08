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

final class CandleStickDataManager {
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
