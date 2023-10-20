//
//  PercentChange.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 09.10.2023.
//

import UIKit


class PercentChange: UIView {
    private let percentLabel = UILabel()
    private let color: UIColor
    var detailViewController: DetailViewController!
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        percentLabel.text = title
        if Double(title)! >= 0 {
            percentLabel.textColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
        } else {
            percentLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        }
    }
    
    private func setupSubviews() {
        percentLabel.textColor = .darkText
        percentLabel.font = .systemFont(ofSize: 13)
        percentLabel.textAlignment = .right
        
        addSubview(percentLabel)
        
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            percentLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 290),
        ])
    }
}


