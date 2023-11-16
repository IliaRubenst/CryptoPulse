//
//  Endpoints.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

enum Endpoint {
    
//    case createAccount(path: String = "/auth/create-account", userRequest: RegisterUserRequest)
    case createAccount(path: String = "/auth/users/", userRequest: RegisterUserRequest)
    case getAlarms(path: String = "/get_alarms/", userID: Int)
    case signIn(path: String = "/auth/token/login/", userRequest: SignInUserRequest)
    case forgotPassword(path: String = "/auth/users/reset_password/", email: String)
    case signOut(path: String = "/auth/token/logout")
    case currentUser(path: String = "/auth/users/me/")
    case submitTelegramChatID(path: String = "/telegram_user_chatid/", submitForm: SubmitTelegramChatIDRequest)
    case getTelegramChatID(path: String = "/get_telegram_chatid/", userID: Int)
    
    var request: URLRequest? {
        guard let url = self.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod
        request.addValues(for: self)
        request.httpBody = self.httpBody
        
        return request
    }
    
    private var url: URL? {
        var components = URLComponents()
        components.scheme = HttpConstants.scheme
        components.host = HttpConstants.baseURL
        components.port = HttpConstants.port
        components.path = self.path
        return components.url
    }
    
    private var path: String {
        switch self {
        case .signIn(let path, _),
            .signOut(let path),
            .forgotPassword(let path, _),
            .createAccount(let path, _),
            .currentUser(let path),
            .submitTelegramChatID(let path, _),
            .getTelegramChatID(let path, _),
            .getAlarms(let path, _):
            return path
        }
    }
    
    private var httpMethod: String {
        switch self {
        case .createAccount,
            .signIn,
            .signOut,
            .submitTelegramChatID,
            .getAlarms,
            .getTelegramChatID,
            .forgotPassword:
            return HTTP.Method.post.rawValue
        case .currentUser:
            return HTTP.Method.get.rawValue
            
        }
    }
    
    private var httpBody: Data? {
        switch self {
        case .createAccount(_, let userRequest):
            return try? JSONEncoder().encode(userRequest)
        
        case .signIn(_, let userRequest):
            return try? JSONEncoder().encode(userRequest)
            
        case .forgotPassword(_, let email):
            return try? JSONSerialization.data(withJSONObject: ["email": email], options: [])
            
        case .submitTelegramChatID(_, let submitRequest):
            return try? JSONEncoder().encode(submitRequest)
            
        case .getAlarms(_, let userID):
            return try? JSONSerialization.data(withJSONObject: ["userID": userID], options: [])
            
        case .getTelegramChatID(_, let userID):
            return try? JSONSerialization.data(withJSONObject: ["userID": userID], options: [])
            
        case .currentUser,
            .signOut:
            return nil
            
        }
    }
}

extension URLRequest {
    
    mutating func addValues(for endpoint: Endpoint) {
        switch endpoint {
        case .createAccount,
            .signIn,
            .getAlarms,
            .signOut,
            .currentUser,
            .submitTelegramChatID,
            .getTelegramChatID,
            .forgotPassword:
            self.setValue(HTTP.Headers.Value.applicationJson.rawValue, forHTTPHeaderField: HTTP.Headers.Key.contentType.rawValue)
        }
    }
}
