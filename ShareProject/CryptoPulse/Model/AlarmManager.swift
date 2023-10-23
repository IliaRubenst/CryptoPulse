//
//  AlarmManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 23.10.2023.
//

import Foundation
import UIKit
import LightweightCharts

class AlarmManager {
    weak var detailViewController: UIViewController?
    var chartManager: ChartManager!
    
    private var alarmLine: PriceLine!
    
    init(detailViewController: UIViewController, chartManager: ChartManager) {
        self.detailViewController = detailViewController
        self.chartManager = chartManager
    }
    
    var isAlertShowing: Bool = false
    
    func setupAlarmLines() {
        for alarm in AlarmModelsArray.alarms {
            setupAlarmLine(alarm.alarmPrice, id: String(alarm.id))
        }
    }
    
    func setupAlarmLine(_ alarmPrice: Double, id: String) {
        let options = PriceLineOptions(
            id: id,
            price: alarmPrice,
            color: "#f00",
            lineWidth: .one,
            lineStyle: .solid
        )

        alarmLine = chartManager.series?.createPriceLine(options: options)
    }
    
    func removeAlarmLine(_ index: Int) {
        chartManager.series.removePriceLine(line: AlarmModelsArray.alarmaLine[index])
    }
    
    
    func alarmObserver(for symbol: String, equal closePrice: Double) {
        let upToDown = "сверху вниз"
        let downToUp = "снизу вверх"
//        var telegramAlram = TelegramNotifications()

        for (index, state) in AlarmModelsArray.alarms.enumerated() where state.isActive && symbol == state.symbol {
            if (state.isAlarmUpper && closePrice >= state.alarmPrice) ||
                (!state.isAlarmUpper && closePrice <= state.alarmPrice) {
                let direction = state.isAlarmUpper ? downToUp : upToDown
//                telegramAlram.message = "Цена \(state.symbol) пересекла \(state.alarmPrice) \(direction)"
                showAlertForAlarm(symbol: state.symbol, alarmPrice: state.alarmPrice, direction: direction)
                
                AlarmModelsArray.alarms[index].isActive = false
            }
        }
    }
    
    func showAlertForAlarm(symbol: String, alarmPrice: Double, direction: String) {
        if isAlertShowing { return }
        let ac = UIAlertController(title: "Alarm for \(symbol)",
                                   message: "The price crossed \(alarmPrice) \(direction)",
                                   preferredStyle: .alert)
        isAlertShowing = true
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isAlertShowing = false
        })
        detailViewController?.present(ac, animated: true)
    }
}
