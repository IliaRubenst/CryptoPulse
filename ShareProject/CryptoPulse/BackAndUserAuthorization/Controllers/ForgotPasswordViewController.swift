//
//  ForgotPasswordViewController.swift
//  userLoginWithNode
//
//  Created by Vitaly on 10.10.2023.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    private let headerView = AuthHeader(title: "Forgot password", subtitle: "Reset your password")
    private let emailField = CustomTextField(fieldType: .email)
    private let resetPassword = CustomButton(title: "Submit", hasBackGround: true, fontSize: .big)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        resetPassword.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(resetPassword)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        resetPassword.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 230),
            
            emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 11),
            emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 55),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            resetPassword.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            resetPassword.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            resetPassword.heightAnchor.constraint(equalToConstant: 55),
            resetPassword.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
    
    @objc private func didTapForgotPassword() {
        guard let email = self.emailField.text, !email.isEmpty else {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        // TODO: - Email validation
        
        // Email check
        if !Validator.isValidEmail(for: email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        guard let request = Endpoint.forgotPassword(email: email).request else { return }
        
        Task {
            do {
                try await AuthService.forgotPasswordFetch(request: request)
                AlertManager.showPasswordResetSentAlert(on: self)
                
            } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.emptyFieldError(let message), ServerErrorResponse.decodingError(let message) {
                AlertManager.showErrorSendingPasswordResetAlert(on: self, with: message)
            }
        }
    }
}
