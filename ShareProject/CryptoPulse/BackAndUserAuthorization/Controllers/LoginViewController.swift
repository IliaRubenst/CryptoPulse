//
//  LoginViewController.swift
//  userLoginWithNode
//
//  Created by Vitaly on 10.10.2023.
//

import UIKit

class LoginViewController: UIViewController {

    private let headerView = AuthHeader(title: "Sign In", subtitle: "Sign in to your account")
    
    private let usernameField = CustomTextField(fieldType: .userName)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signInButton = CustomButton(title: "Sign In", hasBackGround: true, fontSize: .big)
    private let newUserButton = CustomButton(title: "New User? Create account.", fontSize: .medium)
    private let forgotPasswordButton = CustomButton(title: "Forgot Password?", fontSize: .small)
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    
    
    @objc private func didTapSignIn() {
        
        let userRequest = SignInUserRequest(
            username: self.usernameField.text ?? "",
            password: self.passwordField.text ?? "")
        
        // Email check
        if !Validator.isValidUsername(for: userRequest.username) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        // Password check
        if !Validator.isPasswordValid(for: userRequest.password) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        
        
        Task {
            guard let request = Endpoint.signIn(userRequest: userRequest).request else { return }
            
            await loginFetch(request: request)
            await userFetch()
                    
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
        }
    }
    
    func loginFetch(request: URLRequest) async {
        do {
            if let authToken = try await AuthService.loginFetch(request: request) {
                AuthToken.authToken = authToken
                
                DataLoader.saveData(for: "AuthToken")
                
//                let userDefaults = DataLoader(keys: "AuthToken")
//                userDefaults.saveData()
            }
        } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
            AlertManager.showSignInErrorAlert(on: self, with: message)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func userFetch() async {
        do {
            if let user = try await DataService.getUser() {
                SavedCurrentUser.user = user
                
                DataLoader.saveData(for: "CurrentUser")
                
//                let userDefaults = DataLoader(keys: "CurrentUser")
//                userDefaults.saveData()
                
            }
        } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
            print("DEBUG: \(message)")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func didTapNewUser() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(headerView)
        self.view.addSubview(usernameField)
        self.view.addSubview(passwordField)
        
        self.view.addSubview(signInButton)
        self.view.addSubview(newUserButton)
        self.view.addSubview(forgotPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        newUserButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.headerView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 222),
            
            self.usernameField.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 12),
            self.usernameField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.usernameField.heightAnchor.constraint(equalToConstant: 55),
            self.usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.passwordField.topAnchor.constraint(equalTo: self.usernameField.bottomAnchor, constant: 22),
            self.passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.passwordField.heightAnchor.constraint(equalToConstant: 55),
            self.passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.signInButton.topAnchor.constraint(equalTo: self.passwordField.bottomAnchor, constant: 22),
            self.signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.signInButton.heightAnchor.constraint(equalToConstant: 55),
            self.signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.newUserButton.topAnchor.constraint(equalTo: self.signInButton.bottomAnchor, constant: 11),
            self.newUserButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.newUserButton.heightAnchor.constraint(equalToConstant: 44),
            self.newUserButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            self.forgotPasswordButton.topAnchor.constraint(equalTo: self.newUserButton.bottomAnchor, constant: 6),
            self.forgotPasswordButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            self.forgotPasswordButton.heightAnchor.constraint(equalToConstant: 55),
            self.forgotPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85)
        ])
    }

}
