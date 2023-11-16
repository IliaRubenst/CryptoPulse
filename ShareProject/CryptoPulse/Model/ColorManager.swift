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
    
    static func setAlarmColor(alarmID: String) -> String? {
        return AlarmModelsArray.alarms.first(where: { $0.alarmID == alarmID })?.alarmColor
    }
}

extension UIColor {
    static func colorBasedOnValue(_ value: Double) -> UIColor {
        return value >= 0 ? ColorManager.positiveColor : ColorManager.negativeColor
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIColor {
    var hexString: String? {
        if let components = cgColor.components, components.count >= 3 {
            let r = Float(components[0])
            let g = Float(components[1])
            let b = Float(components[2])
            return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
        return nil
    }
}


