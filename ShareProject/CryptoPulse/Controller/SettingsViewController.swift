//
//  SettingsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 05.10.2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    var userChatID: String?
    
    let userView = UserView(username: SavedCurrentUser.user.userName, email: SavedCurrentUser.user.email)
    let userIDTextField = CustomTextField(fieldType: .telegramChatID)
    
    let userIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Telegram Chat ID"
        label.textColor = .black
        
        return label
    }()
    
    let saveIDButton = CustomButton(title: "Save ID", hasBackGround: true, fontSize: .medium)
    
    let resetButton = CustomButton(title: "Reset ID", hasBackGround: true, fontSize: .medium)
    
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
        view.addSubview(userView)
        
        setupConstraints()
        
    }
    
    func setupConstraints() {
        userView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([userView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                                     userView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     userView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                     userView.heightAnchor.constraint(equalToConstant: 60)])
        
        
        
        
        userIDLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([userIDLabel.topAnchor.constraint(equalTo: userView.bottomAnchor, constant: 20),
                                     userIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)])
        
        userIDTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([userIDTextField.topAnchor.constraint(equalToSystemSpacingBelow: userIDLabel.bottomAnchor, multiplier: 1),
                                     userIDTextField.heightAnchor.constraint(equalToConstant: 55),
                                     userIDTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                                     userIDTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)])
        
        saveIDButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([saveIDButton.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20),
                                     saveIDButton.leadingAnchor.constraint(equalTo: userIDTextField.leadingAnchor),
                                     saveIDButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -5),
                                     saveIDButton.heightAnchor.constraint(equalToConstant: 40)])
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([resetButton.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 20),
                                     resetButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 5),
                                     resetButton.trailingAnchor.constraint(equalTo: userIDTextField.trailingAnchor),
                                     resetButton.heightAnchor.constraint(equalToConstant: 40)])
        
        loguotButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([loguotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                                     loguotButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                                     loguotButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                                     loguotButton.heightAnchor.constraint(equalToConstant: 55)])
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
        userChatID = id
    }
    
    func configureButtons() {
        userIDTextField.delegate = self
        saveIDButton.addTarget(self, action: #selector(didTapSaveID), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetIDTapped), for: .touchUpInside)
        loguotButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    // На данный момент метод никакие данные не обновляет.
    @objc func didTapSaveID() {
        /*
        
        Key.userID = userID
        userIDTextField.isEnabled = false
         */
        
        guard let userChatID,
              let id = SavedCurrentUser.user.id else { return }
        
        let submitForm = SubmitTelegramChatIDRequest(userID: id, userChatID: userChatID)
        
        Task {
            guard let request = Endpoint.submitTelegramChatID(submitForm: submitForm).request else { return }
            
            do {
                try await DataService.submitTelegramUserChatID(request: request)
                
            } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
                print("DEBUG PRINT: \(message)")
            } catch {
                print(error.localizedDescription)
            }
        }
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

