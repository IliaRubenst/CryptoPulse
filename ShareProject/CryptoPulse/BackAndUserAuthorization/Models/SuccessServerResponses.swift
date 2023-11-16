//
//  SuccessServerResponses.swift
//  CyptoPulse
//
//  Created by Vitaly on 08.11.2023.
//

import Foundation

struct SuccessUserRegistrationResponse: Decodable {
    let email: String
    let username: String
    let id: Int
}

struct SuccessUserLoginResponse: Decodable {
    let authToken: String
}

struct CurrentUserResponse: Decodable {
    let email: String
    let id: Int
    let username: String
}

struct SuccessTelegramChatIDResponse: Decodable {
    let id: Int
    let userID: Int
    let userChatID: String
}
