//
//  CustomButtons.swift
//  CyptoPulse
//
//  Created by Vitaly on 02.10.2023.
//

import UIKit

struct TwoLabelsButtonViewModel {
    let leftLabel: String
    let rightLabel: String
}

class TwoLabelsButton: UIButton {
    
    var viewModel: TwoLabelsButtonViewModel?
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    init(with viewModel: TwoLabelsButtonViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        configure(with: viewModel)
    }
    
    override init(frame: CGRect) {
        self.viewModel = nil
        super.init(frame: frame)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftLabel.frame = CGRect(x: 10, y: 0, width: frame.width / 2, height: frame.height).integral
        rightLabel.frame = CGRect(x: frame.width / 2, y: 0, width: (frame.width / 2) - 10, height: frame.height).integral
    }
    
    func configure(with viewModel: TwoLabelsButtonViewModel) {
        leftLabel.text = viewModel.leftLabel
        rightLabel.text = viewModel.rightLabel
    }
}

class LabelTextFiledButton: UIButton, UITextFieldDelegate {
    
    let leftLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let textField: UITextField = {
        let textFiled = UITextField()
        return textFiled
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(leftLabel)
        leftLabel.text = "Цена"
        
        addSubview(textField)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftLabel.frame = CGRect(x: 10, y: 0, width: frame.width / 2, height: frame.height).integral
        textField.frame = CGRect(x: frame.width / 2, y: 0, width: (frame.width / 2) - 10, height: frame.height).integral
    }
    
    func configureTextField() {        
        textField.keyboardType = .decimalPad
        textField.textAlignment = .right
        textField.textColor = .white
        textField.tintColor = .white
    }
}

class LabelColorButton: UIButton {
    let leftLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let colorWell: UIColorWell = {
        let colorWell = UIColorWell()
        
        colorWell.supportsAlpha = false
        colorWell.selectedColor = .systemGreen
        colorWell.title = "Выберите цвет"
        return colorWell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(leftLabel)
        leftLabel.text = "Цвет"
        
        addSubview(colorWell)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftLabel.frame = CGRect(x: 10, y: 0, width: frame.width / 2, height: frame.height).integral
        colorWell.frame = CGRect(x: frame.width - 50, y: 5, width: 40, height: frame.height - 10).integral
    }
}
