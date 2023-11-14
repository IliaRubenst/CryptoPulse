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

// В запросах не обрабатываются ошибки с сервера.

final class DataBaseManager {
    private let baseURLString = "http://127.0.0.1:8000/api/account"
//    let baseURLString = "https://cryptopulseapp.ru/api/account"
    private let authorizationValue = "Token \(AuthToken.authToken)"
    
    func performRequestDB(completion: @escaping (Data?, Error?) -> Void) {
        performTaskWithRequestType(.GET, urlString: baseURLString, body: nil, completion: completion)
    }
    
    func addAlarmtoModelDB(alarmModel: AlarmModel, completion: @escaping (Data?, Error?) -> Void) {
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
//        performTaskWithRequestType(.POST, urlString: baseURLString, body: encoded, completion: completion)
        
        // Testing request
        performTaskWithRequestType(.POST, urlString: "http://127.0.0.1:8000/alarms_db/", body: encoded, completion: completion)
    }
    
    func updateDBData(alarmModel: AlarmModel, change id: String) {
//        let urlString = baseURLString.appending("/\(id)")
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
//        performTaskWithRequestType(.PUT, urlString: urlString, body: encoded, completion: { _, _ in })
        
        
        // Test Request
        performTaskWithRequestType(.PUT, urlString: "http://127.0.0.1:8000/alarms_db/", body: encoded, completion: { _, _ in })
    }
    
    func removeDBData(remove alarmID: String) {
//        let urlString = baseURLString.appending("/\(id)")
//        print(urlString)
//        performTaskWithRequestType(.DELETE, urlString: urlString, body: nil, completion: { _, _ in })
        
        // Testing request
        guard let encodedID = try? JSONEncoder().encode(["alarmID": alarmID]) else { return }
        performTaskWithRequestType(.DELETE, urlString: "http://127.0.0.1:8000/alarms_db/", body: encodedID, completion: { _, _ in })
        
    }
    
    private func performTaskWithRequestType(_ type: HTTPMethod,
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
    
    private func createRequest(with url: URL, type: String, body: Data?) -> URLRequest {
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
    
    private func parseJSONDB(DBData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([AlarmModel].self, from: DBData)
            
//            guard let username = SavedCurrentUser.user.userName else { return }
            
            AlarmModelsArray.alarms = decodedData
            /*
            for data in decodedData where data.userName == username {
                AlarmModelsArray.alarms.append(AlarmModel(id: data.id,
                                                          userName: data.userName,
                                                          symbol: data.symbol,
                                                          alarmPrice: Double(data.alarmPrice),
                                                          isAlarmUpper: data.isAlarmUpper,
                                                          isActive: data.isActive,
                                                          creationDate: data.creationDate)
            )}
            */
            DataLoader.saveData(for: "savedAlarms")

//            let defaults = DataLoader(keys: "savedAlarms")
//            defaults.saveData()
        } catch {
            print(error.localizedDescription)
        }
    }
}
