//
//  DataBaseManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 12.10.2023.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class DataBaseManager {
//        let baseURLString = "http://127.0.0.1:8000/api/account/"
    let baseURLString = "https://cryptopulseapp.ru/api/account/"
    let authorizationValue = "Basic aWxpYTpMSmtiOTkyMDA4MjIh"
    
    func performRequestDB(completion: @escaping (Data?, Error?) -> Void) {
        performTaskWithRequestType(.GET, urlString: baseURLString, body: nil, completion: completion)
    }
    
    func addAlarmtoModelDB(alarmModel: AlarmModel, completion: @escaping (Data?, Error?) -> Void) {
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
        performTaskWithRequestType(.POST, urlString: baseURLString, body: encoded, completion: completion)
    }
    
    func updateDBData(alarmModel: AlarmModel, change id: Int) {
        let urlString = baseURLString.appending("\(id)/")
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
        performTaskWithRequestType(.PUT, urlString: urlString, body: encoded, completion: { _, _ in })
    }
    
    func removeDBData(remove id: Int) {
        let urlString = baseURLString.appending("\(id)/")
        performTaskWithRequestType(.DELETE, urlString: urlString, body: nil, completion: { _, _ in })
    }
    
    func performTaskWithRequestType(_ type: HTTPMethod,
                                    urlString: String,
                                    body: Data?,
                                    completion: @escaping (Data?, Error?) -> Void) {
        
        if let url = URL(string: urlString) {
            
            let request = createRequest(with: url, type: type.rawValue, body: body)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async { [self] in
                    if let safeData = data, safeData.count != 0, type == .GET  {
                        parseJSONDB(DBData: safeData)
                    }
                }
                
                completion(data, error)
            }.resume()
            
            print("Make \(request.httpMethod!) request to:\(url)")
            
        }
    }
    
    func createRequest(with url: URL, type: String, body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let bodyData = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData
        }
        request.addValue(authorizationValue, forHTTPHeaderField: "Authorization")
        return request
    }
    
    func parseJSONDB(DBData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Account].self, from: DBData)
            for data in decodedData {
                let currentDate = AlarmManager.convertCurrentDateToString()
                
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
