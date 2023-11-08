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
    
    static func registerFetchTest(request: URLRequest) async throws {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 201 || response.statusCode == 400 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let _ = try? decoder.decode(SuccessUserRegistrationResponse.self, from: data) {
                return
            }
            
            if let detailError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(detailError.detail)
            }
            
            if let alreadyRegistred = try? decoder.decode(UsernameAlreadyRegistredResponse.self, from: data),
               let message = alreadyRegistred.username.first {
                throw ServerErrorResponse.detailError(message)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    static func loginFetch(request: URLRequest) async throws -> String? {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode == 400 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            if let success = try? decoder.decode(SuccessUserLoginResponse.self, from: data) {
                return success.authToken
                
            } else if let nonFieldError = try? decoder.decode(LoginFailureResponse.self, from: data),
                      let message = nonFieldError.nonFieldErrors.first {
                throw ServerErrorResponse.detailError(message)
                
            } else if let detailError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(detailError.detail)
                
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    static func logoutFetch() async throws {
        guard var request = Endpoint.signOut().request else { return }
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 204 || response.statusCode == 401 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        if response.statusCode == 204 {
            print("DEBUG PRINT: Успешный логаут")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let tokenError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(tokenError.detail)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    static func forgotPasswordFetch(request: URLRequest) async throws {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 204 || response.statusCode == 400 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        if response.statusCode == 204 {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let emailError = try? decoder.decode(BlankFieldError.self, from: data),
               let message = emailError.email.first {
                throw ServerErrorResponse.emptyFieldError(message)
            }
            
            if let jsonError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(jsonError.detail)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    /*static func fetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
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
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            if let _ = try? decoder.decode(SuccessUserRegistrationResponse.self, from: data) {
                complition(.success("Вы успешно зарегистрированы"))
                return
            }
                
            if let loginSuccessMessage = try? decoder.decode(SuccessUserLoginResponse.self, from: data) {
                complition(.success(loginSuccessMessage.authToken))
                return
                
            }
            
            if let errorMessage = try? decoder.decode(UsernameAlreadyRegistredResponse.self, from: data) {
                guard let errorMessage = errorMessage.username.first else { return }
                complition(.failure(ServiceError.serverError(errorMessage)))
                return
                
            } else if let errorMessage = try? decoder.decode(LoginFailureResponse.self, from: data) {
                guard let errorMessage = errorMessage.nonFieldErrors.first else { return }
                complition(.failure(ServiceError.serverError(errorMessage)))
                return
                
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }*/
    
    /*static func forgotPasswordFetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
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
    }*/
    
    // MARK: Sign Out
    /*static func logoutFetch(request: URLRequest, complition: @escaping (Result<String, Error>) -> Void) {
        
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
            
            if let invalidTokenServerMessage = try? decoder.decode(TokenErrorServerResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(invalidTokenServerMessage.detail)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
            
        }.resume()
    }*/
}
