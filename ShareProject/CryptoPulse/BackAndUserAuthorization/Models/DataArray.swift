//
//  DataArray.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

struct DataArray: Decodable {
    let data: [String]
}

struct AuthToken {
    static var authToken = String()
}
