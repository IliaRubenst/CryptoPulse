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
        titleLabel.textColor = .darkText
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .left
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}


