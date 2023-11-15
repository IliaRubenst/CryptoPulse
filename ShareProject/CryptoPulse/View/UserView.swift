//
//  UserView.swift
//  CyptoPulse
//
//  Created by Vitaly on 15.11.2023.
//

import UIKit

class UserView: UIView {

    private let userLogo: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "person.circle")
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.text = "Error"
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.text = "Error"
        return label
    }()
    
    init(username: String?, email: String?) {
        super.init(frame: .zero)
        self.usernameLabel.text = username
        self.emailLabel.text = email
        
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(userLogo)
        self.addSubview(usernameLabel)
        self.addSubview(emailLabel)
        
        userLogo.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userLogo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            userLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            userLogo.widthAnchor.constraint(equalToConstant: 60),
            userLogo.heightAnchor.constraint(equalTo: userLogo.widthAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: userLogo.trailingAnchor, constant: 10),
            usernameLabel.topAnchor.constraint(equalTo: userLogo.topAnchor),
        
            emailLabel.leadingAnchor.constraint(equalTo: userLogo.trailingAnchor, constant: 10),
            emailLabel.bottomAnchor.constraint(equalTo: userLogo.bottomAnchor)])
    }
    
}
