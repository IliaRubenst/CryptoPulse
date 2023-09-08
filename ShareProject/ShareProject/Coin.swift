//
//  Coin.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

class Coin: Decodable {
    let assets: [Assets]
}

struct Assets: Decodable {
    let asset: String
}
