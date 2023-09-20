//
//  DataModel.swift
//  ShareProject
//
//  Created by Ilia Ilia on 12.09.2023.
//

import Foundation
import LightweightCharts

struct MarkPriceStreamModel {
    var symbol: String
    var markPrice: String
    var indexPrice: String
    var fundingRate: String
    var nextFindingTime: Double
}

struct CurrentCandleModel {
    let eventTime: Int
    let pair: String
    let interval: String
    let openPrice: String
    let closePrice: String
    let highPrice: String
    let lowPrice: String
    let isKlineClose: Bool
}

struct PreviousCandlesModel {
    let openTime: Double
    let openPrice: String
    let highPrice: String
    let lowPrice: String
    let closePrice: String
    let volume: String
    let closeTime: Int
    let quoteAssetVolume: String
    let numberOfTrades: Int
    let takerBuyVolume: String
    let takerBuyQuoteAssetVolume: String
}

struct AlarmModel {
    let symbol: String
    let alarmPrice: Double
    let isAlarmUpper: Bool
    var isActive: Bool
}

struct AlarmModelsArray {
    static var alarms = [AlarmModel]()
    static var alarmaLine = [PriceLine]()
}

