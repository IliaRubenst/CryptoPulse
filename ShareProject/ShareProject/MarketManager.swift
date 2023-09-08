//
//  MarketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import Foundation

struct MarketManager {
    let binanceURL = "https://fapi.binance.com"
    
    func fetchRequest(path: String, action: () -> ()) {
        let urlString = binanceURL + path
        performRequest(urlString: urlString)
        print(urlString)
        action()
    }
    
    func performRequest(urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            
            let task = session.dataTask(with: url) { [self] (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    parseJSON(marketData: safeData)
                }
            }
            // 4. Start the task
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
