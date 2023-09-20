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
        getRequest(urlString: urlString)
    }
    
    func getRequest(urlString: String) {
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
    
    func postRequest() {
        guard let url = URL(string: "https://api.telegram.org/bot6620191491:AAHKCwMWZuLgs34U1OS7ZNgbpzRGYVBjBRg/sendMessage") else { return }
        let parameters = ["chat_id": "133744737", "text": "Теперь\nя могу писать\nпредложения с пробелами\nИ с новыми параграфами"]
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
