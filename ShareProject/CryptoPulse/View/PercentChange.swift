//
//  PercentChange.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 09.10.2023.
//

import UIKit


final class PercentChange: UIView {
    private let percentLabel = UILabel()
    private let color: UIColor
    weak var detailViewController: ChartViewController!
    
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
        if let value = Double(title) {
            percentLabel.textColor = UIColor.colorBasedOnValue(value)
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


