//
//  CustomCollectionViewCell.swift
//  CyptoPulse
//
//  Created by Vitaly on 19.10.2023.
//

import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    static let identifier = "CustomCollectionViewCell"
    
    private let tickerLabel = UILabel()
    private let currentPriceLabel = UILabel()
    private let volumeLabel = UILabel()
    let percentChangeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemGray5
        setupLabels()
        setupConstraints()

    }
    
    private func setupLabels() {
        [tickerLabel, currentPriceLabel, volumeLabel, percentChangeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 5
        
        NSLayoutConstraint.activate([
            tickerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            tickerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
                                 
            percentChangeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            percentChangeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),

            currentPriceLabel.topAnchor.constraint(equalTo: percentChangeLabel.bottomAnchor, constant: padding),
            currentPriceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),

            volumeLabel.topAnchor.constraint(equalTo: currentPriceLabel.bottomAnchor, constant: padding),
            volumeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetLabels()
    }
    
    func removeCell(at index: Int) {
        UserSymbols.savedSymbols.remove(at: index)
    }
    
    func changeColor() {
        contentView.backgroundColor = contentView.backgroundColor == .white ? .systemGray5 : .white
    }
    
    func configure(with symbol: Symbol) {
            let formattedSymbol = formatTickerLabelText(with: symbol)
            tickerLabel.text = formattedSymbol
            tickerLabel.numberOfLines = 0
            currentPriceLabel.text = symbol.markPrice
            volumeLabel.text = symbol.volume
            percentChangeLabel.text = "\(symbol.priceChangePercent ?? "0") %"
            
        tickerLabel.font = UIFont.systemFont(ofSize: 16)
            currentPriceLabel.font = UIFont.systemFont(ofSize: 16)
            volumeLabel.font = UIFont.systemFont(ofSize: 16)
            percentChangeLabel.font = UIFont.systemFont(ofSize: 16)
        }
        
    func formatTickerLabelText(with symbol: Symbol) -> String {
        if symbol.symbol.contains("USDT") {
            let parts = symbol.symbol.components(separatedBy: "USDT")
            guard let firstPart = parts.first else { return symbol.symbol }
            return "\(firstPart)/\nUSDT"
        } else {
            let parts = symbol.symbol.components(separatedBy: "BUSD")
            guard let firstPart = parts.first else { return symbol.symbol }
            return "\(firstPart)/\nВUSD"
        }
    }
    
    private func resetLabels() {
        [tickerLabel, currentPriceLabel, volumeLabel, percentChangeLabel].forEach { $0.text = nil }
    }
}
