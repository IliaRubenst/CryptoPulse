//
//  CustomCollectionViewCell.swift
//  CyptoPulse
//
//  Created by Vitaly on 19.10.2023.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    static let identifier = "CustomCollectionViewCell"
    
    var tickerLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var currentPriceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var volumeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var percentChangeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemGray5
        
        self.addSubview(tickerLabel)
        self.addSubview(currentPriceLabel)
        self.addSubview(volumeLabel)
        self.addSubview(percentChangeLabel)
        
        
        tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        percentChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([tickerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
                                     tickerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
                                     
                                     percentChangeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
                                     percentChangeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
                                    
                                     currentPriceLabel.topAnchor.constraint(equalTo: percentChangeLabel.bottomAnchor, constant: 5),
                                     currentPriceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
                                    
                                     volumeLabel.topAnchor.constraint(equalTo: currentPriceLabel.bottomAnchor, constant: 5),
                                     volumeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)])
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.tickerLabel.text = nil
        self.percentChangeLabel.text = nil
        self.currentPriceLabel.text = nil
        self.volumeLabel.text = nil
    }
    
    
    func removeCell(_ index: Int) {
        UserSymbols.savedSymbols.remove(at: index)
    }
    
    
    func changeColor() {
        if contentView.backgroundColor == #colorLiteral(red: 0.9112530351, green: 0.9112530351, blue: 0.9112530351, alpha: 1) {
            contentView.backgroundColor = .white
        } else {
            contentView.backgroundColor = #colorLiteral(red: 0.9112530351, green: 0.9112530351, blue: 0.9112530351, alpha: 1)
        }
    }
}
