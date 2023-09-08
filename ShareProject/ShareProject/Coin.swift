//
//  Coin.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

struct Coin: Decodable {
//    let assets: [Assets]
    let symbols: Symbol
}

//struct Assets: Decodable {
//    let asset: String
//}

struct Symbol: Decodable {
    let symbol: String
    let markPrice: String
}

struct SymbolsArray {
    static var symbols = [Symbol]()
}

    /*
{
    "symbol": "BTCUSDT",
    "markPrice": "11012.80409769",
    "lastFundingRate": "-0.03750000",
    "nextFundingTime": 1562569200000,
    "time": 1562566020000
}
     */


