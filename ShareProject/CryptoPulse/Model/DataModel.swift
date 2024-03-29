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
    var nextFundingTime: Double
    
    func timeTodateFormat(nextFindingTime: Double) -> String {
        let dateTime = DateFormatter()
        dateTime.dateFormat = "HH:mm:ss"
        let nextFundingTime = Date(timeIntervalSince1970: nextFindingTime)
        
        return dateTime.string(from: nextFundingTime)
    }
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

struct IndividualSymbolTickerStreamsModel {
    let symbol: String
    let volumeBase: String
    let volumeQuote: String
    let closePrice: String
    let openPrice: String
    let highPrice: String
    let lowPrice: String
    let priceChangePercent: String
}

struct AlarmModel: Codable, Hashable {
    let userID: Int
    let alarmID: String
    let symbol: String
    var alarmPrice: Double
    var isAlarmUpper: Bool
    var isActive: Bool
    let creationDate: String
    var alarmColor: String
}

struct AlarmModelsArray {
    static var alarms = [AlarmModel]()
    static var alarmaLine = [PriceLine]()
}


