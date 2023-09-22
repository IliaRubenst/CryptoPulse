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
    var detailViewController: DetailViewController!
    
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
        let button1Image = UIImage(systemName: "bell")?.withTintColor(#colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1), renderingMode: .alwaysOriginal)
        button1.setImage(button1Image, for: .normal)
//        button1.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
//        button1.setTitle("Set alarm", for: .normal)
        
        button1.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        let button2 = UIButton(type: .system)
        let button2Image = UIImage(systemName: "bell.badge")?.withTintColor(#colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1), renderingMode: .alwaysOriginal)
        button2.setImage(button2Image, for: .normal)
//        button2.backgroundColor = #colorLiteral(red: 0.9078041315, green: 0.9078041315, blue: 0.9078040719, alpha: 1)
        //        button2.setTitle("Set price for alarm", for: .normal)
        button2.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button2.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        menuStackView.addArrangedSubview(button1)
        menuStackView.addArrangedSubview(button2)
        
        button1.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2Pressed), for: .touchUpInside)
    }
    
    @objc func button1Pressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "anyBtnPressed"), object: nil)
    }
    
    @objc func button2Pressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "button2Pressed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "anyBtnPressed"), object: nil)
    }
}
