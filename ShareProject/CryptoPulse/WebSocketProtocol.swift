//
//  WebSocketProtocol.swift
//  CyptoPulse
//
//  Created by Vitaly on 04.10.2023.
//

import Foundation

protocol WebSocketManagerDelegate {
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel)
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel)
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel)
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol])
}

extension WebSocketManagerDelegate {
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {}
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {}
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {}
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol]) {}
}
