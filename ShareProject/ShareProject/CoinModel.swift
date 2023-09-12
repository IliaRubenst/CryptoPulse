//
//  CoinModel.swift
//  ShareProject
//
//  Created by Ilia Ilia on 12.09.2023.
//

import Foundation


struct CoinModel {
    var closePrice: String
    var openPrice: String
    var highPrice: String
    var lowPrice: String
}

struct CurrentCandleModel {
    let eventTime: Int
    let pair: String
    let interval: String
    let openPrice: String
    let closePrice: String
    let highPrice: String
    let lowPrice: String
}
