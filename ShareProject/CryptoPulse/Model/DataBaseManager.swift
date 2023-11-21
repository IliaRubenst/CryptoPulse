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
// теперь обрабатываются

final class DataBaseManager {
    private let baseURLString = "http://127.0.0.1:8000/alarms_db/"
//    let baseURLString = "https://cryptopulseapp.ru/alarms_db/"
    private let authorizationValue = "Token \(AuthToken.authToken)"
    
    func performRequestDB(userID: Int) /*, completion: @escaping (Data?, Error?) -> Void)*/ {
        Task {
            do {
                if let alarmsArray = try await DataService.getAlarms(for: userID) {
                    AlarmModelsArray.alarms = alarmsArray
                }
            } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
                print("DEBUG: \(message)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addAlarmtoModelDB(alarmModel: AlarmModel, completion: @escaping (Data?, Error?) -> Void) {
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
        performTaskWithRequestType(.POST, urlString: baseURLString, body: encoded, completion: completion)
    }
    
    func updateDBData(alarmModel: AlarmModel, change id: String) {
        guard let encoded = try? JSONEncoder().encode(alarmModel) else {
            print("Failed to encode new alarm")
            return
        }
        performTaskWithRequestType(.PUT, urlString: baseURLString, body: encoded, completion: { _, _ in })
    
    }
    
    func removeDBData(remove alarmID: String) {
        guard let encodedID = try? JSONEncoder().encode(["alarmID": alarmID]) else { return }
        performTaskWithRequestType(.DELETE, urlString: baseURLString, body: encodedID, completion: { _, _ in })
    }
    
    private func performTaskWithRequestType(_ type: HTTPMethod,
                                            urlString: String,
                                            body: Data?,
                                            completion: @escaping (Data?, Error?) -> Void) {
        
        if let url = URL(string: urlString) {
            
            let request = createRequest(with: url, type: type.rawValue, body: body)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(nil, error)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
//                        print("Successful request.")
                        
                        if let data = data {
                            DispatchQueue.main.async {
                                if data.count != 0 {
                                    self.parseJSONDB(DBData: data)
                                }
                            }
                            completion(data, nil)
                        }
                    case 400..<500:
                        print("Client error: \(response.statusCode).")
                        completion(nil, NSError(domain: urlString, code: response.statusCode, userInfo: nil))
                    case 500..<600:
                        print("Server error: \(response.statusCode).")
                        completion(nil, NSError(domain: urlString, code: response.statusCode, userInfo: nil))
                    default:
                        print("Unexpected status code: \(response.statusCode)")
                        completion(nil, NSError(domain: urlString, code: response.statusCode, userInfo: nil))
                    }
                    
                    return
                }
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
            AlarmModelsArray.alarms = decodedData
            
            DataLoader.saveData(for: "savedAlarms")
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
