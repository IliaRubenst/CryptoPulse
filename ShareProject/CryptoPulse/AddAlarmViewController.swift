//
//  AddAlarmViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 27.09.2023.
//

import UIKit

class AddAlarmViewController: UIViewController, UITextFieldDelegate {
    
    var symbol: String = "Инструмент"
    var price: String = ">"
    var color: UIColor = .systemRed
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Уведомление"
        label.font = UIFont.systemFont(ofSize: 22)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.contentMode = .scaleToFill
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var symbolButton: TwoLabelsButton = {
        let button = TwoLabelsButton()
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white
        button.rightLabel.textColor = .white
        return button
    }()
    
    var priceButton: LabelTextFiledButton = {
        let button = LabelTextFiledButton()
        
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white       
        
        return button
    }()
    
    var colorButton: LabelColorButton = {
        let button = LabelColorButton()
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDoneButton()
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([titleLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([dismissButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)])
        
        NSLayoutConstraint.activate([saveButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),])
        
        NSLayoutConstraint.activate([mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                                     mainStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     mainStack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     ])
        
        NSLayoutConstraint.activate([symbolButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     symbolButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     symbolButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([priceButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     priceButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     priceButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([colorButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     colorButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     colorButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
    func setupKeyboardDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        priceButton.textField.inputAccessoryView = toolBar
    }
    
    @objc func didTapDone() {
        view.endEditing(true)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        
        view.addSubview(saveButton)
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(symbolButton)
        mainStack.addArrangedSubview(priceButton)
        mainStack.addArrangedSubview(colorButton)
    }
    
    func configureButtons() {
        symbolButton.configure(with: TwoLabelsButtonViewModel(leftLabel: symbol, rightLabel: price))
        priceButton.textField.delegate = self
        symbolButton.addTarget(self, action: #selector(openSymbolsList), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    @objc func openSymbolsList() {
        let table = SymbolsListController()
        table.senderState = .alarmsView
        table.alarmsViewController = self
        
        present(table, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            print(text)
        }
    }
}
