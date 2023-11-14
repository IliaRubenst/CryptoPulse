//
//  DataService.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

class DataService {
    
    static func getAlarms(for userID: Int) async throws -> [AlarmModel]? {
        
        guard var request = Endpoint.getAlarms(userID: userID).request else { return nil }
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode == 401 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let alarmsArray = try? decoder.decode([AlarmModel].self, from: data) {
                return alarmsArray
            } else if let tokenError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(tokenError.detail)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    static func getUser() async throws -> CurrentUser? {
        
        guard var request = Endpoint.currentUser().request else { return nil }
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode == 401 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let userResponse = try? decoder.decode(CurrentUserResponse.self, from: data) {
                let currentUser = CurrentUser(email: userResponse.email, id: userResponse.id, userName: userResponse.username)
                return currentUser
            } else if let tokenError = try? decoder.decode(DetailError.self, from: data) {
                throw ServerErrorResponse.detailError(tokenError.detail)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    static func submitTelegramUserChatID(request: URLRequest) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode == 400 else {
            throw ServerErrorResponse.invalidResponse(response.debugDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            
            if let _ = try? decoder.decode(SuccessTelegramChatIDSumbit.self, from: data) {
                return
            }
            
            if let error = try? decoder.decode(TelegramSubmitError.self, from: data) {
                throw ServerErrorResponse.detailError(error.message)
            } else {
                throw ServerErrorResponse.decodingError()
            }
        } catch {
            throw error
        }
    }
    
    /*static func getData(complition: @escaping (Result<[Account], Error>) -> Void) {
        
        guard var request = Endpoint.getData().request else { return }
        
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
    
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
            
            if let array = try? decoder.decode([Account].self, from: data) {
                complition(.success(array))
                print("Успешно декодим полученные данные!")
                return
            } else if let errorMessage = try? decoder.decode(ErrorResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(errorMessage.error)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }*/
    
    /*static func getUser(complition: @escaping (Result<CurrentUserResponse, Error>) -> Void) {
        
        guard var request = Endpoint.currentUser().request else { return }
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
        
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
            
            if let currentUserModel = try? decoder.decode(CurrentUserResponse.self, from: data) {
                complition(.success(currentUserModel))
                return
            } else if let tokenError = try? decoder.decode(TokenErrorServerResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(tokenError.detail)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }*/
    
    
    
}
