//
//  MarketManager.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import Foundation

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
    
    private func parseJSON(marketData: Data) -> Result<[Symbol], Error> {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Symbol].self, from: marketData)
            let filteredData = decodedData.filter { !$0.symbol.contains("_") }
            let sortedData = filteredData.sorted(by: { $0.symbol < $1.symbol })
            let symbols = sortedData.map { Symbol(symbol: $0.symbol, markPrice: $0.markPrice) }
            return .success(symbols)
        } catch {
            return .failure(error)
        }
    }
}
