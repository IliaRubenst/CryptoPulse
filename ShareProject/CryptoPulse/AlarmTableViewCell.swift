//
//  AlarmTableViewCell.swift
//  CyptoPulse
//
//  Created by Vitaly on 26.09.2023.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

   static let identifier = "AlarmCell"
    
    let labelColor: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Missed to fill label"
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Missed to fill label"
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Missed to fill label"
        label.textAlignment = .right
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Missed to fill label"
        label.textAlignment = .right
        return label
    }()
    
    let horizontalStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.contentMode = .scaleToFill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let leftVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.contentMode = .scaleToFill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let rightVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.contentMode = .scaleToFill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.contentView.addSubview(labelColor)
        
        NSLayoutConstraint.activate([
            labelColor.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            labelColor.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            labelColor.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            labelColor.widthAnchor.constraint(equalToConstant: 5)])
        
        self.contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: labelColor.trailingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)])
        
        horizontalStackView.addArrangedSubview(leftVerticalStackView)
        horizontalStackView.addArrangedSubview(rightVerticalStackView)
        
        leftVerticalStackView.addArrangedSubview(tickerLabel)
        leftVerticalStackView.addArrangedSubview(dateLabel)
        
        rightVerticalStackView.addArrangedSubview(priceLabel)
        rightVerticalStackView.addArrangedSubview(statusLabel)
        
        NSLayoutConstraint.activate([tickerLabel.leadingAnchor.constraint(equalTo: labelColor.trailingAnchor, constant: 10),
                                     dateLabel.leadingAnchor.constraint(equalTo: labelColor.trailingAnchor, constant: 10),
                                     priceLabel.trailingAnchor.constraint(equalTo: rightVerticalStackView.trailingAnchor, constant: -10),
                                     statusLabel.trailingAnchor.constraint(equalTo: rightVerticalStackView.trailingAnchor, constant: -10)])
    }
    
}
