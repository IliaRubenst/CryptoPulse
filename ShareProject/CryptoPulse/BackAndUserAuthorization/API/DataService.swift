//
//  DataService.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

class DataService {
    
    static func getData(complition: @escaping (Result<[Account], Error>) -> Void) {
        
        guard var request = Endpoint.getData().request else { return }
        
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
//        request.addValue("*/*", forHTTPHeaderField: "Accept")
        
//        print(request.url)
//        print(request.httpMethod)
//        print(request.allHTTPHeaderFields)
        
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
    }
    
}
