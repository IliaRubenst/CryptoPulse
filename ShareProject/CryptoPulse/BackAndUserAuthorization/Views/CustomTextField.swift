//
//  CustomTextField.swift
//  userLoginWithNode
//
//  Created by Vitaly on 10.10.2023.
//

import UIKit

enum CustomTextFieldType {
    case userName
    case email
    case password
    case telegramChatID
}

class CustomTextField: UITextField {
    
    private let authFieldType: CustomTextFieldType
    
    init(fieldType: CustomTextFieldType) {
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .userName:
            self.placeholder = "Username"
        case .email:
            self.placeholder = "Email address"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.placeholder = "Password"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
        case .telegramChatID:
            self.placeholder = "Введите ваш Telegram Chat ID"
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
