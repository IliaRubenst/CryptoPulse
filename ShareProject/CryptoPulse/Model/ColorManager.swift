//
//  ColorManager.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 20.10.2023.
//

import UIKit


final class ColorManager {
    static let positiveColor = UIColor(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
    static let negativeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    
    static func percentValueToColor(_ percentChangeString: String?) -> UIColor {
        let value = Double(percentChangeString ?? "0") ?? 0
        return UIColor.colorBasedOnValue(value)
    }
    
    static func changeSymbolsListCellColor(symbol: Symbol, cell: SymbolsListCell) {
        let color = percentValueToColor(symbol.priceChangePercent)
        cell.symbolLabel.textColor = color
        cell.percentChangeLabel.textColor = color
    }
    
    static func changeCoinCell(indexPath: IndexPath, cell: CustomCollectionViewCell) {
        let color = percentValueToColor(UserSymbols.savedSymbols[indexPath.item].priceChangePercent)
        cell.percentChangeLabel.textColor = color
        cell.layer.borderColor = color.cgColor
    }
    
    static func percentText(priceChangePercent: String, rightLowerNavLabel: UILabel) {
        rightLowerNavLabel.textColor = percentValueToColor(priceChangePercent)
    }
    
    static func setBackgroundForButton(buttonNames: [UIButton], timeFrame: String ) {
         for name in buttonNames {
             if name.titleLabel?.text == timeFrame {
                 name.backgroundColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
             } else {
                 name.backgroundColor = .clear
             }
         }
     }
}

extension UIColor {
    static func colorBasedOnValue(_ value: Double) -> UIColor {
        return value >= 0 ? ColorManager.positiveColor : ColorManager.negativeColor
    }
}
