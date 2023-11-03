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
    let id: Int
    let userName: String
    let symbol: String
    var alarmPrice: Double
    let isAlarmUpper: Bool
    var isActive: Bool
    let creationDate: String
}


struct CurrentUser: Codable, CustomStringConvertible {
    var email: String?
    var id: Int?
    var userName: String?
    
    var description: String {
        return "Current User Description:\nEmail: \(String(describing: self.email))\nID: \(String(describing: self.id))\nUsername: \(String(describing: self.userName))"
    }
}

struct SavedCurrentUser {
    static var user = CurrentUser()
}

struct AlarmModelsArray {
    static var alarms = [AlarmModel]()
    static var alarmaLine = [PriceLine]()
}


