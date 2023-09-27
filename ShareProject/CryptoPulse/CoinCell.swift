//
//  CoinCell.swift
//  ShareProject
//
//  Created by Ilia Ilia on 08.09.2023.
//

import UIKit

class CoinCell: UICollectionViewCell {
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    
    func removeCell(_ index: Int) {
        UserSymbols.savedSymbols.remove(at: index)
    }
    
    func changeColor() {
        if contentView.backgroundColor == #colorLiteral(red: 0.9112530351, green: 0.9112530351, blue: 0.9112530351, alpha: 1) {
            contentView.backgroundColor = .white
        } else {
            contentView.backgroundColor = #colorLiteral(red: 0.9112530351, green: 0.9112530351, blue: 0.9112530351, alpha: 1)
        }
    }
}
