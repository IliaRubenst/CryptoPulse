//
//  TooltipView.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

final class TooltipView: UIView {
    private let accentColor: UIColor
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .left
        return label
    }()
    
    init(accentColor: UIColor) {
        self.accentColor = .black
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        self.accentColor = .black
        super.init(coder: coder)
        
        isUserInteractionEnabled = false
        setupSubviews()
        setupConstraints()
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.textColor = accentColor
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //сюда можно будет добавить констрейты и убрать их из чарт менеджера
    }
}


