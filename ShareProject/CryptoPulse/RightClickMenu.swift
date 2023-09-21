//
//  RightClickMenu.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 20.09.2023.
//

import UIKit

class RightClickMenu: UIView {
//    private let menuView = UIView()
    private let menuStackView = UIStackView()
    private let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        
        layer.borderWidth = 2
        layer.cornerRadius = 5
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupSubviews() {
        self.layer.borderColor = color.cgColor
        
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        
        menuStackView.axis = .horizontal
        menuStackView.distribution = .fillEqually
        menuStackView.alignment = .center
        menuStackView.spacing = 3

        addSubview(menuStackView)
        
        let button1 = UIButton(type: .system)
        button1.setTitle("Button 1", for: .normal)
        let button2 = UIButton(type: .system)
        button2.setTitle("Button 2", for: .normal)
        let button3 = UIButton(type: .system)
        button3.setTitle("Button 3", for: .normal)
        
        menuStackView.addArrangedSubview(button1)
        menuStackView.addArrangedSubview(button2)
        menuStackView.addArrangedSubview(button3)
        
        button1.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
    }
    
    @objc func button1Pressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
    }
}
