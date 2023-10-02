//
//  Coin.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

//struct Coin: Codable {
//    var symbols: Symbol
//}

class Symbol: Codable {
    var symbol: String
    var markPrice: String
    var volume: String?
    var priceChangePercent: String?
    
    init(symbol: String, markPrice: String, volume: String? = nil, priceChangePercent: String? = nil) {
        self.symbol = symbol
        self.markPrice = markPrice
        self.volume = volume
        self.priceChangePercent = priceChangePercent
    }
    
//    func volumeFormat(volume: String) -> String {
//        let volume = Double(volume) ?? 0 / 1_000_000
//        let volume24h = String(format: "%.2fm$", volume)
//        
//        return volume24h
//    }
}

class FullSymbolData: Codable {
    var s: String
    var P: String
    var c: String
    var q: String
    
    init(symbol: String, priceChangePercent: String, markPrice: String, volume: String) {
        self.s = symbol
        self.P = priceChangePercent
        self.c = markPrice
        self.q = volume
    }
}

struct FullSymbolModel {
    var symbol: String
    var markPrice: String
    var volume: String
    
    init(symbol: String, markPrice: String, volume: String) {
        self.symbol = symbol
        self.markPrice = markPrice
        self.volume = volume
    }
}

struct FullSymbolsArray {
    static var fullSymbols = [FullSymbolData]()
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

struct IndividualSymbolTickerStreamsData: Codable {
    var s: String
    var v: String
    var q: String
    var c: String
    var o: String
    var h: String
    var l: String
    var P: String
    
    init(symbol: String, volumeBase: String, volumeQuote: String, closePrice: String, openPrice: String, highPrice: String, lowPrice: String, priceChangePercent: String) {
        self.s = symbol
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

struct Account: Codable, Hashable {
    let id: Int
    let symbol: String
    let alarmPrice: Float
    let isAlarmUpper: Bool
    let isActive: Bool
}

struct AccountModel {
    static var accounts = [Account]()
}

