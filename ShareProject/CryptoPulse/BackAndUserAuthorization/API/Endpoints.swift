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
    case getData(path: String = "/api/account")
    case signIn(path: String = "/auth/token/login/", userRequest: SignInUserRequest)
    case forgotPassword(path: String = "/auth/users/reset_password/", email: String)
    case signOut(path: String = "/auth/token/logout")
    
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
            .getData(let path):
            return path
        }
    }
    
    private var httpMethod: String {
        switch self {
        case .createAccount,
            .signIn,
            .signOut,
            .forgotPassword:
            return HTTP.Method.post.rawValue
        case .getData:
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
            
        case .getData,
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
            .getData,
            .signOut,
            .forgotPassword:
            self.setValue(HTTP.Headers.Value.applicationJson.rawValue, forHTTPHeaderField: HTTP.Headers.Key.contentType.rawValue)
        }
    }
}
