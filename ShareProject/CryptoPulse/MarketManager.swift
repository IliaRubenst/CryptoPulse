//
//  MarketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import Foundation

struct MarketManager {
    let binanceURL = "https://fapi.binance.com"
    var path = "/fapi/v1/premiumIndex"
    
    func fetchRequest() {
        let urlString = binanceURL + path
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { [self] (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    parseJSON(marketData: safeData)
                }
            } 

            task.resume()
        }
    }
    
    func parseJSON(marketData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Symbol].self, from: marketData)
            
            for data in decodedData.sorted(by: { $0.symbol < $1.symbol }) {
                SymbolsArray.symbols.append(Symbol(symbol: data.symbol, markPrice: data.markPrice))
            }
        } catch {
            print(error)
        }
    }
}
