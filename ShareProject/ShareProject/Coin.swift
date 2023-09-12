//
//  Coin.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

struct Coin: Codable {
//    let assets: [Assets]
    let symbols: Symbol
}

struct Symbol: Codable {
    let symbol: String
    let markPrice: String
}

struct SymbolsArray {
    static var symbols = [Symbol]()
}

struct SymbolPriceData: Codable {
    var s: String
    var p: String
    
    init(symbol: String, price: String) {
        self.s = symbol
        self.p = price
    }
}

struct VolumeData: Codable {
    var v: String
    var q: String
    var c: String
    var o: String
    var h: String
    var l: String
    
    init(volumeBase: String, volumeQuote: String, closePrice: String, openPrice: String, highPrice: String, lowPrice: String) {
        self.v = volumeBase
        self.q = volumeQuote
        self.c = closePrice
        self.o = openPrice
        self.h = highPrice
        self.l = lowPrice
    }
}

struct CurrentCandleData: Codable {
    let E: Int
    let ps: String
    let k: K

}

struct K: Codable {
    let t: Int
    let T: Int
    let i: String
    let o: String
    let c: String
    let h: String
    let l: String
    let x: Bool
}

