//
//  Notifications.swift
//  ShareProject
//
//  Created by Vitaly on 15.09.2023.
//

import Foundation

struct TelegramNotifications {
    let urlTelegramAPI = "https://api.telegram.org/bot"
    let botToken = "" // сюда вставлять апи ключ
    var user_ID = 133744737
    var message = String()
    var sendMessageMethodPath: String {
        "/sendMessage?chat_id=\(String(user_ID))&text=\(message)"
    }
    
    func fetchRequest() {
        let urlString = urlTelegramAPI + botToken + sendMessageMethodPath
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                } else {
                    print("Successfully sent message")
                }
            }
            task.resume()
        }
    }
}
