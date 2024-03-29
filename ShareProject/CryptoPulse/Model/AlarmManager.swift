//
//  AlarmManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 23.10.2023.
//

import Foundation
import UIKit
import LightweightCharts

final class AlarmManager {
    private var alarmLine: PriceLine!
    var chartManager: ChartManager? = nil
    var dbManager = DataBaseManager()
    
    private var upToDown = "сверху вниз"
    private var downToUp = "снизу вверх"
    var id = 0
    var isAlertShowing: Bool = false
    
    init(chartManager: ChartManager?) {
        self.chartManager = chartManager
    }
    
    // Setup alarm lines from model data
    func setupAlarmLines() {
        for alarm in AlarmModelsArray.alarms {
            setupAlarmLine(alarm.alarmPrice, id: String(alarm.alarmID), color: ChartColor(rawValue: alarm.alarmColor))
        }
    }
    
    // Setup a single alarm line
    func setupAlarmLine(_ alarmPrice: Double, id: String, color: ChartColor) {
        let options = PriceLineOptions(
            id: id,
            price: alarmPrice,
            color: color,
            lineWidth: .one,
            lineStyle: .solid
        )
        
        guard let chartManager else { return }
        alarmLine = chartManager.series?.createPriceLine(options: options)
    }
    
    // Removes an alarm line given an index (not currently in use)
    func removeAlarmLine(_ index: Int) {
        guard let chartManager else { return }
        chartManager.series?.removePriceLine(line: AlarmModelsArray.alarmaLine[index])
    }
    
    // Add an alarm and associate it with a detail view controller
    func addAlarm(symbol: String, closePrice: Double, openedChart: ChartViewController) {
        let addAlarmVC = AddAlarmViewController()
        addAlarmVC.symbol = symbol
        addAlarmVC.closePrice = String(closePrice)
        addAlarmVC.symbolButton.isEnabled = false
        addAlarmVC.openedChart = openedChart

        if let sheet = addAlarmVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        openedChart.present(addAlarmVC, animated: true)
    }
    
    static func isAlarmUpper(alarmPrice: Double, closePrice: Double) -> Bool {
        alarmPrice > closePrice ? true : false
    }
    
    func addAlarmAtSetPrice(alarmPrice: Double, closePrice: Double, symbol: String) {
        let isAlarmUpper = AlarmManager.isAlarmUpper(alarmPrice: alarmPrice, closePrice: closePrice)
        let alarmID = UUID().uuidString
        let currentDate = AlarmManager.convertCurrentDateToString()
        let alarmColor = "#f00"
        
        guard let currentUserUserID = SavedCurrentUser.user.id else { return }
        
        let newAlarm = AlarmModel(userID: currentUserUserID, alarmID: alarmID, symbol: symbol, alarmPrice: alarmPrice, isAlarmUpper: isAlarmUpper, isActive: true, creationDate: currentDate, alarmColor: alarmColor)
        
        storeAlarmInDB(newAlarm)
        setupAlarmLine(alarmPrice, id: alarmID, color: ChartColor(rawValue: alarmColor))
    }
    
    func addAlarmForSelectedPrice(alarmPrice: Double, closePrice: Double, symbol: String) {
        let isAlarmUpper = AlarmManager.isAlarmUpper(alarmPrice: alarmPrice, closePrice: closePrice)
        let alarmID = UUID().uuidString
        let currentDate = AlarmManager.convertCurrentDateToString()
        let alarmColor = "#f00"
        
        guard let currentUserUserID = SavedCurrentUser.user.id else { return }
        
        let newAlarm = AlarmModel(userID: currentUserUserID, alarmID: alarmID, symbol: symbol, alarmPrice: alarmPrice, isAlarmUpper: isAlarmUpper, isActive: true, creationDate: currentDate, alarmColor: alarmColor)
        
        storeAlarmInDB(newAlarm)
        setupAlarmLine(alarmPrice, id: alarmID, color: ChartColor(rawValue: alarmColor))
        
    }
    
    // Store alarm in the database
    private func storeAlarmInDB(_ alarm: AlarmModel) {
        dbManager.addAlarmtoModelDB(alarmModel: alarm) { [self] data, error in
            if let error = error {
                DispatchQueue.main.async { [self] in
                    let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    chartManager?.delegate.present(alert, animated: true)
                }
                print("Не удалось создать аларм в БД: \(error.localizedDescription)")
            } else {
                AlarmModelsArray.alarms.removeAll()
                refreshAlarmDataFromDB()
            }
        }
    }
    
    // Refresh alarm data from the database
    private func refreshAlarmDataFromDB() {
        guard let userID = SavedCurrentUser.user.id else { return }
        dbManager.performRequestDB(userID: userID) /*{ (data, error) in
            if let error = error {
                print("Не удалось создать аларм в БД: \(error.localizedDescription)")
            } else {
                print("Аларм успешно создан.")
                
                self.sendPushNotification(message: "Аларм успешно создан")
            }
        }*/
    }
    
    // Check alarm states and notify if the conditions are suitable
    func alarmObserver(for symbol: String, equal closePrice: Double) {
        for (index, state) in AlarmModelsArray.alarms.enumerated() where state.isActive && symbol == state.symbol {
            if alarmTriggered(state: state, closePrice: closePrice) {
                handleTriggeredAlarm(index: index, state: state)
            }
        }
    }
    
    private func alarmTriggered(state: AlarmModel, closePrice: Double) -> Bool {
        return (state.isAlarmUpper && closePrice >= state.alarmPrice) || (!state.isAlarmUpper && closePrice <= state.alarmPrice)
    }
    
    private func handleTriggeredAlarm(index: Int, state: AlarmModel) {
//        var telegramAlram = TelegramNotifications()
        let direction = state.isAlarmUpper ? downToUp : upToDown
        showAlertForAlarm(symbol: state.symbol, alarmPrice: state.alarmPrice, direction: direction)
//        telegramAlram.message = "Цена \(state.symbol) пересекла \(state.alarmPrice) \(direction)"
        AlarmModelsArray.alarms[index].isActive = false
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
        chartManager?.delegate.present(ac, animated: true)
    }
    
    
    static func convertCurrentDateToString() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyy hh:mm"
        let now = df.string(from: Date())
        return now
    }
    
    //можно потом убрать в Notifications
    private func sendPushNotification(message: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Уведомление"
        content.body = message
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "AlarmCreatedNotification", content: content, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("Не удалось отправить push-уведомление: \(error.localizedDescription)")
            } else {
                print("Push-уведомление отправлено успешно.")
            }
        }
    }
}
