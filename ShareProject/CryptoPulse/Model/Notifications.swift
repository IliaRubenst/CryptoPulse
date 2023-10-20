//
//  Notifications.swift
//  ShareProject
//
//  Created by Vitaly on 15.09.2023.
//

import Foundation

struct TelegramNotifications {
    private let urlTelegramAPI = "https://api.telegram.org/bot"
    private var botToken: String? = Key.key // сюда вставлять апи ключ
    private let  methodName = "/sendMessage"
    private var user_ID: String? = Key.userID
    var message = String()

    func postRequest() {
        guard let botToken = botToken,
              let userID = user_ID else { return }
        
        let urlString = urlTelegramAPI + botToken + methodName
        guard let url = URL(string: urlString) else { return }
        let parameters = ["chat_id": userID, "text": message]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else { return }
        request.httpBody = httpBody
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print(json)
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
}
