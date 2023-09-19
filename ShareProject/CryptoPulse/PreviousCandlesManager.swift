////
////  PreviousCandlesManager.swift
////  ShareProject
////
////  Created by Vitaly on 13.09.2023.
////
//
//import Foundation
//
//struct PreviousCandlesManager {
//    
//    var delegate: DetailViewController!
//    var pair: String
//    var interval: String
//    let binanceURL = "https://fapi.binance.com"
//    
//    func fetchRequest() {
//        let path = "/fapi/v1/continuousKlines?pair=\(pair)&contractType=PERPETUAL&interval=\(interval)"
//        let urlString = binanceURL + path
//        print(urlString)
//        performRequest(urlString: urlString)
//    }
//    
//    func performRequest(urlString: String)  {
//        if let url = URL(string: urlString) {
//            let session = URLSession(configuration: .default)
//            let task = session.dataTask(with: url) { [self] (data, response, error) in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                if let safeData = data {
//                    parseJSON(marketData: safeData)
//                    
//                }
//            }
//            task.resume()
//        }
//    }
//    
//    func parseJSON(marketData: Data)  {
//        do {
//            if let decodedData = try JSONSerialization.jsonObject(with: marketData, options: []) as? [[Any]] {
//                for i in 0..<decodedData.count {
//                    let candle = PreviousCandlesModel(openTime: decodedData[i][0] as! Double,
//                                                      openPrice: decodedData[i][1] as! String,
//                                                      highPrice: decodedData[i][2] as! String,
//                                                      lowPrice: decodedData[i][3] as! String,
//                                                      closePrice: decodedData[i][4] as! String,
//                                                      volume: decodedData[i][5] as! String,
//                                                      closeTime: decodedData[i][6] as! Int,
//                                                      quoteAssetVolume: decodedData[i][7] as! String,
//                                                      numberOfTrades: decodedData[i][8] as! Int,
//                                                      takerBuyVolume: decodedData[i][9] as! String,
//                                                      takerBuyQuoteAssetVolume: decodedData[i][10] as! String)
//                    delegate.candles.append(candle)
//                }
//                print("Loaded \(delegate.candles.count) candles")
//            } else {
//                print("Ошибка приведения типа")
//            }
//        } catch let error as NSError {
//            print("Failed to load: \(error.localizedDescription)")
//        }
//        
//    }
//}
