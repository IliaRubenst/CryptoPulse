//
//  Coin.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

struct Coin: Codable {
    var symbols: Symbol
}

class Symbol: Codable {
    var symbol: String
    var markPrice: String
    
    init(symbol: String, markPrice: String) {
        self.symbol = symbol
        self.markPrice = markPrice
    }
}

struct MarkPriceStreamData: Codable {
    var s: String
    var p: String
    var i: String
    var r: String
    var T: Double
    
    init(symbol: String, markPrice: String, indexPrice: String, fundingRate: String, nextFundingTime: Double) {
        self.s = symbol
        self.p = markPrice
        self.i = indexPrice
        self.r = fundingRate
        self.T = nextFundingTime
    }
}

struct VolumeData: Codable {
    var v: String
    var q: String
    var c: String
    var o: String
    var h: String
    var l: String
    var P: String
    
    init(volumeBase: String, volumeQuote: String, closePrice: String, openPrice: String, highPrice: String, lowPrice: String, priceChangePercent: String) {
        self.v = volumeBase
        self.q = volumeQuote
        self.c = closePrice
        self.o = openPrice
        self.h = highPrice
        self.l = lowPrice
        self.P = priceChangePercent
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

