//
//  DataBaseManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 12.10.2023.
//

import Foundation

class DataBaseManager {
    func performRequestDB() {
        if let url = URL(string: "http://94.241.143.198:8000/api/account/") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { [self] data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async { [self] in
                    if let safeData = data {
                        parseJSONDB(DBData: safeData)
                    }
                }
            }.resume()
            print("Make \(request.httpMethod!) request to:\(url)")
        }
    }
    
    func addAlarmtoModelDB(alarmModel: AlarmModel) {
        if let url = URL(string: "http://94.241.143.198:8000/api/account/") {
            
            let alarmModelData = alarmModel
            guard let encoded = try? JSONEncoder().encode(alarmModelData) else {
                print("Failed to encode new alarm")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            request.httpBody = encoded
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
//                    if let response = try? JSONDecoder().decode(AlarmModel.self, from: data) {
                    if (try? JSONDecoder().decode(AlarmModel.self, from: data)) != nil {
                        return
                    }
                    
                }
            }.resume()
        }
    }
    
    func updateDBData(alarmModel: AlarmModel, change id: Int) {
        if let url = URL(string: "http://94.241.143.198:8000/api/account/\(id)/") {
            
            let alarmModelData = alarmModel
            guard let encoded = try? JSONEncoder().encode(alarmModelData) else {
                print("Failed to encode new alarm")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/JSON", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            request.httpBody = encoded
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
//                    if let response = try? JSONDecoder().decode(AlarmModel.self, from: data) {

                    if (try? JSONDecoder().decode(AlarmModel.self, from: data)) != nil {
                        return
                    }
                }
            }.resume()
        }
    }
    
    
    func removeDBData(remove id: Int) {
        if let url = URL(string: "http://94.241.143.198:8000/api/account/\(id)/") {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
            }.resume()
        }
    }
    
    func parseJSONDB(DBData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Account].self, from: DBData)
            for data in decodedData {
                let detailVC = DetailViewController()
                let currentDate = detailVC.convertCurrentDateToString()
                
                AlarmModelsArray.alarms.append(AlarmModel(id: data.id,
                                                          symbol: data.symbol,
                                                          alarmPrice: Double(data.alarmPrice),
                                                          isAlarmUpper: data.isAlarmUpper,
                                                          isActive: data.isActive,
                                                          date: currentDate)
                )}
            let defaults = DataLoader(keys: "savedAlarms")
            defaults.saveData()
        } catch {
            print(error)
        }
    }
    
    
}
