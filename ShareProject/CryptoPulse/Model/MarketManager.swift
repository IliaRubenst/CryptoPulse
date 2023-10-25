//
//  MarketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import Foundation
import LightweightCharts

struct MarketManager {
    let url = URL(string: "https://fapi.binance.com/fapi/v1/premiumIndex")
    
    func fetchRequest(completion: @escaping (Result<[Symbol], Error>) -> Void) {
        guard let url = url else {
            completion(.failure(NSError(domain: "", code: 0)))
            return
        }
        getData(from: url, completion: completion)
    }
    
    private func getData(from url: URL, completion: @escaping (Result<[Symbol], Error>) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let safeData = data {
                completion(parseJSON(marketData: safeData))
            }
        }
        task.resume()
    }
    
    func parseJSON(marketData: Data) -> Result<[Symbol], Error> {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Symbol].self, from: marketData)
            let sortedData = decodedData.sorted(by: { $0.symbol < $1.symbol })
            let symbols = sortedData.map { Symbol(symbol: $0.symbol, markPrice: $0.markPrice) }
            return .success(symbols)
        } catch {
            return .failure(error)
        }
    }
}

// пока не используется(нужен для загрузки данных по старым свечам)
class CandleStickDataManager {
    let binanceURL = "https://fapi.binance.com"
    var delegate: DetailViewController!

    func fetchRequest(symbol: String, timeFrame: String, completion: @escaping ([CandlestickData]) -> Void) {
        let path = "/fapi/v1/continuousKlines?pair=\(symbol)&contractType=PERPETUAL&interval=\(timeFrame)"
        let urlString = binanceURL + path
        performRequest(urlString: urlString, completion: completion)
    }

    func performRequest(urlString: String, completion: @escaping ([CandlestickData]) -> Void)  {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { [self] (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    parseJSON(marketData: safeData, completion: completion)
                }
            }
            task.resume()
        }
    }

    func parseJSON(marketData: Data, completion: @escaping ([CandlestickData]) -> Void)  {
        var candles = [CandlestickData]()
        do {
            if let decodedData = try JSONSerialization.jsonObject(with: marketData, options: []) as? [[Any]] {
                for i in 0..<decodedData.count {
                    let openPrice = decodedData[i][1] as! String
                    let highPrice = decodedData[i][2] as! String
                    let lowPrice = decodedData[i][3] as! String
                    let closePrice = decodedData[i][4] as! String

                    let candle = CandlestickData(time: .utc(timestamp: (decodedData[i][0] as! Double) / 1000),
                                                 open: (Double(openPrice)),
                                                 high: (Double(highPrice)),
                                                 low: (Double(lowPrice)),
                                                 close: (Double(closePrice)))
                    candles.append(candle)
                }
                DispatchQueue.main.async { [self] in
                    delegate.chartManager.setupSeries()
//
//                    if ChartManager.data[0].close! < 1{
//                        ChartManager.numberAfterDecimalPoint = "4"
//                    }
                }
                delegate.startWebSocketManagers()
                completion(candles)
            } else {
                print("Ошибка приведения типа")
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
