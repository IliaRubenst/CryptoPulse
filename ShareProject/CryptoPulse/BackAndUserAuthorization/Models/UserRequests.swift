//
//  RegisterUserRequest.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

struct RegisterUserRequest: Codable {
    let email: String
    let username: String
    let password: String
}

struct SignInUserRequest: Codable {
    let username: String
    let password: String
}

struct SubmitTelegramChatIDRequest: Codable {
    let userID: Int
    let userChatID: String
}

