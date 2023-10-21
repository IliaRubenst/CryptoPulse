//
//  AlarmTableViewCell.swift
//  CyptoPulse
//
//  Created by Vitaly on 26.09.2023.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    static let identifier = "AlarmCell"
    
    var tickerLabel: UILabel!
    var dateLabel: UILabel!
    var priceLabel: UILabel!
    var statusLabel: UILabel!
    
    private var leftVerticalStackView: UIStackView!
    private var rightVerticalStackView: UIStackView!
    private var horizontalStackView: UIStackView!
     
     private func createLabel(withText text: String) -> UILabel {
         let label = UILabel()
         label.text = text
         return label
     }
     
     private let labelColor: UIView = {
         let view = UIView()
         view.backgroundColor = .green
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
     }()
     

     private func createStackView(forAxis axis: NSLayoutConstraint.Axis) -> UIStackView {
         let stackView = UIStackView()
         stackView.contentMode = .scaleToFill
         stackView.axis = axis
         stackView.distribution = .fillEqually
         stackView.translatesAutoresizingMaskIntoConstraints = false
         return stackView
     }
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         setupUI()
     }
     
     required init?(coder: NSCoder) {
         super.init(style: .default, reuseIdentifier: AlarmTableViewCell.identifier)
         setupUI()
     }
     
     private func setupUI() {
         tickerLabel = createLabel(withText: "Missed to fill label")
         dateLabel = createLabel(withText: "Missed to fill label")
         priceLabel = createLabel(withText: "Missed to fill label")
         statusLabel = createLabel(withText: "Missed to fill label")
         
         leftVerticalStackView = createStackView(forAxis: .vertical)
         rightVerticalStackView = createStackView(forAxis: .vertical)
         horizontalStackView = createStackView(forAxis: .horizontal)
         horizontalStackView.alignment = .fill
         
         addLabelColorView()
         addStackViews()
         styleStackViews()
         addSubviewsToStackViews()
     }
     
     private func addLabelColorView() {
         self.contentView.addSubview(labelColor)
         
         NSLayoutConstraint.activate([
             labelColor.topAnchor.constraint(equalTo: self.contentView.topAnchor),
             labelColor.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
             labelColor.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
             labelColor.widthAnchor.constraint(equalToConstant: 5)
         ])
     }
     
     private func addStackViews() {
         self.contentView.addSubview(horizontalStackView)
         
         NSLayoutConstraint.activate([
             horizontalStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
             horizontalStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
             horizontalStackView.leadingAnchor.constraint(equalTo: labelColor.trailingAnchor),
             horizontalStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
         ])
     }
     
     private func styleStackViews() {
         leftVerticalStackView.isLayoutMarginsRelativeArrangement = true
         leftVerticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

         rightVerticalStackView.isLayoutMarginsRelativeArrangement = true
         rightVerticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
     }

     private func addSubviewsToStackViews() {
         horizontalStackView.addArrangedSubview(leftVerticalStackView)
         horizontalStackView.addArrangedSubview(rightVerticalStackView)
         
         leftVerticalStackView.addArrangedSubview(tickerLabel)
         leftVerticalStackView.addArrangedSubview(dateLabel)
         
         rightVerticalStackView.addArrangedSubview(priceLabel)
         rightVerticalStackView.addArrangedSubview(statusLabel)
     }
}
