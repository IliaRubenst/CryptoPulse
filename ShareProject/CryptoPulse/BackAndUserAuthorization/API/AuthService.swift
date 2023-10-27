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
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                
                if let error = error {
                    complition(.failure(ServiceError.serverError(error.localizedDescription)))
                } else {
                    complition(.failure(ServiceError.unknownError()))
                }
                
                return
            }
            
            let decoder = JSONDecoder()
            
            if let registerSuccessMessage = try? decoder.decode(SuccessUserRegistrationResponse.self, from: data) {
                complition(.success(/*successMessage.success*/ "Успешно!"))
                return
            } else if let loginSuccessMessage = try? decoder.decode(SuccessUserLoginResponse.self, from: data) {
                complition(.success(loginSuccessMessage.auth_token))
                return
            } else if let errorMessage = try? decoder.decode(ErrorResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(errorMessage.error)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }
    
    // MARK: Sign Out
    static func sighOut() {
        let url = URL(string: HttpConstants.fullURL)!
        let cookie = HTTPCookieStorage.shared.cookies(for: url)!.first!
        
        HTTPCookieStorage.shared.deleteCookie(cookie)
    }
}
