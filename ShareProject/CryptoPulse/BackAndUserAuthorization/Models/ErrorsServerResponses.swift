//
//  ServerResponses.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

enum ServerErrorResponse: Error {
    case invalidResponse(String)
    case detailError(String)
    case decodingError(String = "Error parsing server response.")
    case emptyFieldError(String = "Some requiered fields are empty")
}

struct DetailError: Decodable {
    let detail: String
}

struct UsernameAlreadyRegistredResponse: Decodable {
    let username: [String]
}

struct LoginFailureResponse: Decodable {
    let nonFieldErrors: [String]
}

struct BlankFieldError: Decodable {
    let username: [String]
    let password: [String]
    let email: [String]
}


