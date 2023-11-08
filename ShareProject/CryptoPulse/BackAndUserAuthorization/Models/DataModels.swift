//
//  DataModels.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

struct AuthToken {
    static var authToken = String()
}

struct CurrentUser: Codable, CustomStringConvertible {
    var email: String?
    var id: Int?
    var userName: String?
    
    var description: String {
        return "Current User Description:\nEmail: \(String(describing: self.email))\nID: \(String(describing: self.id))\nUsername: \(String(describing: self.userName))"
    }
}

struct SavedCurrentUser {
    static var user = CurrentUser()
}
