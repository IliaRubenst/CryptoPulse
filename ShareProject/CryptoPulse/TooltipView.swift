//
//  TooltipView.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

class TooltipView: UIView {
    private let titleLabel = UILabel()
    private let accentColor: UIColor
    
    init(accentColor: UIColor) {
        self.accentColor = accentColor
        super.init(frame: .zero)
        
//        layer.borderWidth = 2
//        backgroundColor = .white
        isUserInteractionEnabled = false
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
    
    private func setupSubviews() {
//        self.layer.borderColor = accentColor.cgColor
        
        titleLabel.textColor = .darkText
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .left
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        let padding: CGFloat = 5
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
//        ])

    }
    
}
