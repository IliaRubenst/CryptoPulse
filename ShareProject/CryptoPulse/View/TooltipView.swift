//
//  TooltipView.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

class TooltipView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()
    
    private let accentColor: UIColor
    
    init(accentColor: UIColor) {
        self.accentColor = accentColor
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        titleLabel.textColor = .darkText
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}


