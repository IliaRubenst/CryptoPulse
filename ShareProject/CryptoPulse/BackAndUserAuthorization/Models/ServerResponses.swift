//
//  ServerResponses.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

struct SuccessResponse: Decodable {
    let success: String
}

struct ErrorResponse: Decodable {
    let error: String
}

struct SuccessUserRegistrationResponse: Decodable {
    let email: String
    let username: String
    let id: Int
}

struct SuccessUserLoginResponse: Decodable {
    let auth_token: String
}

struct LogoutErrorServerResponse: Decodable {
    let detail: String
}

struct UsernameAlreadyRegistredResponse: Decodable {
    let username: [String]
}

struct LoginFailureResponse: Decodable {
    let non_field_errors: [String]
}
