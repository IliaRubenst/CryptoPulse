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

struct SymbolPriceData: Decodable {
    var s: String
    var p: String
    
    init(symbol: String, price: String) {
        self.s = symbol
        self.p = price
    }
}

struct VolumeData: Decodable {
    var v: String
    var q: String
    
    init(v: String, q: String) {
        self.v = v
        self.q = q
    }
}
