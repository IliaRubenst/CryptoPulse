//
//  SymbolsListCell.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 27.09.2023.
//

import UIKit

final class SymbolsListCell: UITableViewCell {
    static let identifier = "CustomCell"
    
    private let cellStackView = UIStackView()
    private let rightSideCellStackView = UIStackView()
    let symbolLabel = makeLabel(textAlignment: .left)
    let priceLabel = makeLabel(textAlignment: .left)
    let volumeLabel = makeLabel(textAlignment: .left)
    let percentChangeLabel = makeLabel(textAlignment: .left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    public func configure(symbol: String, price: String, volume: String, percentChange: String) {
        self.symbolLabel.text = symbol
        self.priceLabel.text = price
        self.volumeLabel.text = volume
        self.percentChangeLabel.text = percentChange
    }
    
    private static func makeLabel(textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = textAlignment
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupUI() {
        self.contentView.addSubview(cellStackView)
        
        [priceLabel, volumeLabel, percentChangeLabel].forEach {
            rightSideCellStackView.addArrangedSubview($0)
        }
        
        setupStackViewAttributes(stackView: rightSideCellStackView, axis: .vertical, distribution: .equalCentering, alignment: .leading)
        setupStackViewAttributes(stackView: cellStackView, axis: .horizontal, distribution: .fillEqually, alignment: .center)
        
        [symbolLabel, rightSideCellStackView].forEach {
            cellStackView.addArrangedSubview($0)
        }
        
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    cellStackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
                    cellStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
                    cellStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
                    cellStackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
                ])
    }
    
    private func setupStackViewAttributes(stackView: UIStackView, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution,
                                          alignment: UIStackView.Alignment, spacing: CGFloat = 0.5) {
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
    }
}
