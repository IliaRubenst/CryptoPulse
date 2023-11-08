//
//  SettingsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 05.10.2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    var userID: String?
    
    let userIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите ваш Telegram User ID"
        label.textColor = .black
        
        return label
    }()
    
    let userIDTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        
        return textField
    }()
    
    let saveIDButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Save ID", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Reset ID", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let loguotButton: CustomButton = {
        let button = CustomButton(title: "Выйти", hasBackGround: true, fontSize: FontSize.medium)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureGestureRecogniser()
        configureButtons()
        
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(userIDTextField)
        view.addSubview(saveIDButton)
        view.addSubview(resetButton)
        view.addSubview(userIDLabel)
        view.addSubview(loguotButton)
        
        setupConstraints()
        
    }
    
    func setupConstraints() {
        userIDLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([userIDLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
                                     userIDLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)])
        
        userIDTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([userIDTextField.topAnchor.constraint(equalToSystemSpacingBelow: userIDLabel.bottomAnchor, multiplier: 1),
                                     userIDTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                                     userIDTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)])
        
        saveIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([saveIDButton.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20),
                                     saveIDButton.leadingAnchor.constraint(equalTo: userIDTextField.leadingAnchor),
                                     saveIDButton.widthAnchor.constraint(equalTo: userIDTextField.widthAnchor, multiplier: 0.45)])
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([resetButton.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20),
                                     resetButton.trailingAnchor.constraint(equalTo: userIDTextField.trailingAnchor),
                                     resetButton.widthAnchor.constraint(equalTo: userIDTextField.widthAnchor, multiplier: 0.45)])
        
        loguotButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([loguotButton.topAnchor.constraint(equalTo: saveIDButton.bottomAnchor, constant: 20),
                                     loguotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     loguotButton.heightAnchor.constraint(equalToConstant: 55),
                                     loguotButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)])
                                    
    }
    
    func configureGestureRecogniser() {
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecogniser.delegate = self
        view.addGestureRecognizer(gestureRecogniser)
    }
    
    
    @objc func handleTap(sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Тут надо доделать проверку на пробелы и прочее говно.
        
        guard let id = textField.text else { return }
        userID = id
    }
    
    func configureButtons() {
        userIDTextField.delegate = self
        userIDTextField.placeholder = "User ID"
        saveIDButton.addTarget(self, action: #selector(saveIDTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetIDTapped), for: .touchUpInside)
        loguotButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    // На данный момент метод никакие данные не обновляет.
    @objc func saveIDTapped() {
        /*
        guard let userID else { return }
        Key.userID = userID
        userIDTextField.isEnabled = false
         */
    }
    
    @objc func resetIDTapped() {
        userIDTextField.isEnabled = true
        userIDTextField.becomeFirstResponder()
    }
    
    @objc func logout() {
        let ac = UIAlertController(title: "Выход", message: "Выйти из вашего аккаунта?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Нет", style: .cancel))
        ac.addAction(UIAlertAction(title: "Да, выйти", style: .default, handler: { [weak self] _ in
            
            Task {
                guard let self = self else { return }
                
                do {
                    try await AuthService.logoutFetch()
                    
                    AuthToken.authToken = String()
                    SavedCurrentUser.user = CurrentUser()
                    
                    DataLoader.saveData(for: "AuthToken")
                    DataLoader.saveData(for: "CurrentUser")
                    
//                    var userDefaults = DataLoader(keys: "AuthToken")
//                    userDefaults.saveData()
//
//                    userDefaults = DataLoader(keys: "CurrentUser")
//                    userDefaults.saveData()
                    
                    print("DEBUG: \(AuthToken.authToken)")
                    print(SavedCurrentUser.user.description)
                    
                    if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                        sceneDelegate.checkAuthentication()
                    }
                    
                } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
                    AlertManager.showLogOutErrorAlert(on: self, with: message)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }))
        present(ac, animated: true)
    }
    
    deinit {
        print("SettingsViewController деинициализрован")
    }
}

