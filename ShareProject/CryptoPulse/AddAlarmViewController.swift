//
//  AddAlarmViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 27.09.2023.
//

import UIKit

class AddAlarmViewController: UIViewController {
    
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
        stackView.backgroundColor = .lightGray
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let firstButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([titleLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)])
        
        view.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)])
        
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),])
        
        let someView = UIView()
        someView.backgroundColor = .lightGray
        someView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([mainStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
                                     mainStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     mainStack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     ])
        
        configureButton()
        
        mainStack.addArrangedSubview(firstButton)
        
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    func configureButton() {
        firstButton.setTitle("Button", for: .normal)
        firstButton.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
    }
    
    @objc func firstButtonTapped() {
        print("Tapped")
    }
    

}
