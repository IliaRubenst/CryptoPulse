//
//  RightClickMenu.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 20.09.2023.
//

import UIKit


class RightClickMenu: UIView {
    private let menuStackView = UIStackView()
    private let color: UIColor
    weak var detailViewController: DetailViewController!
    private let buttonSize: CGFloat = 30
    private let systemNames = ["bell", "bell.badge"]
    private let buttonSelectors = [#selector(button1Pressed), #selector(button2Pressed)]
    
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
        
        setupMenuStackView()
        setupButtons()
    }
    
    private func setupMenuStackView() {
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        menuStackView.axis = .horizontal
        menuStackView.distribution = .fillEqually
        menuStackView.alignment = .center
        menuStackView.spacing = 3
        addSubview(menuStackView)
    }
    
    private func setupButtons() {
        for (index, systemName) in systemNames.enumerated() {
            let button = UIButton(type: .system)
            let buttonImage = UIImage(systemName: systemName)?.withTintColor(#colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1), renderingMode: .alwaysOriginal)
            button.setImage(buttonImage, for: .normal)
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.addTarget(self, action: buttonSelectors[index], for: .touchUpInside)
            menuStackView.addArrangedSubview(button)
        }
    }
    
    @objc func button1Pressed() {
        postNotifications(buttonPressed: "button1Pressed")
    }
    
    @objc func button2Pressed() {
        postNotifications(buttonPressed: "button2Pressed")
    }
    
    private func postNotifications(buttonPressed: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: buttonPressed), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "anyBtnPressed"), object: nil)
    }
}

// не используется, делался для возможности перетаскивать priceLine
class AlarmIndicator: UIView {
    private let indicator = UIImageView()
    private let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        indicator.image = UIImage(systemName: "alarm")?.withTintColor(#colorLiteral(red: 1, green: 0.1268401444, blue: 0.1294748783, alpha: 1), renderingMode: .alwaysOriginal)
        
        self.layer.borderColor = color.cgColor
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
    }
}
