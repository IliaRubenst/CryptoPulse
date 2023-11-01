//
//  AuthService.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

enum ServiceError: Error {
    case serverError(String)
    case unknownError(String = "An unknown error occured.")
    case decodingError(String = "Error parsing server response.")
}

class AuthService {
    
    static func fetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            
            guard let data = data else {
                
                if let error = error {
                    complition(.failure(ServiceError.serverError(error.localizedDescription)))
                } else {
                    complition(.failure(ServiceError.unknownError()))
                }
                
                return
            }
            
            let decoder = JSONDecoder()
            
            if let _ = try? decoder.decode(SuccessUserRegistrationResponse.self, from: data) {
                complition(.success("Вы успешно зарегистрированы"))
                return
            }
                
            if let loginSuccessMessage = try? decoder.decode(SuccessUserLoginResponse.self, from: data) {
                complition(.success(loginSuccessMessage.auth_token))
                return
                
            }
            
            if let errorMessage = try? decoder.decode(UsernameAlreadyRegistredResponse.self, from: data) {
                guard let errorMessage = errorMessage.username.first else { return }
                complition(.failure(ServiceError.serverError(errorMessage)))
                return
                
            } else if let errorMessage = try? decoder.decode(LoginFailureResponse.self, from: data) {
                guard let errorMessage = errorMessage.non_field_errors.first else { return }
                complition(.failure(ServiceError.serverError(errorMessage)))
                return
                
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }
    
    // MARK: Sign Out
    static func logoutFetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            
            if let urlResponse = urlResponse as? HTTPURLResponse {
                if urlResponse.statusCode == 204 {
                    complition(.success("Успешный логаут."))
                    return
                }
            }
            
            guard let data = data else {
                if let error = error {
                    complition(.failure(ServiceError.serverError(error.localizedDescription)))
                } else {
                    complition(.failure(ServiceError.unknownError()))
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            if let invalidTokenServerMessage = try? decoder.decode(LogoutErrorServerResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(invalidTokenServerMessage.detail)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
            
        }.resume()
    }
    
    static func forgotPasswordFetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            
            if let urlResponse = urlResponse as? HTTPURLResponse {
                if urlResponse.statusCode == 204 {
                    complition(.success("Успешный выслали ссылку на смену пароля."))
                    return
                }
            }
            
            if let error = error {
                complition(.failure(ServiceError.serverError(error.localizedDescription)))
            } else {
                complition(.failure(ServiceError.unknownError()))
            }
            return
            
        }.resume()
    }
}
