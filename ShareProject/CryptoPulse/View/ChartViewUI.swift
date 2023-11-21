//
//  DetailViewUI.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 25.10.2023.
//

import Foundation
import UIKit

final class ChartViewUI {
    unowned var viewController: ChartViewController
    
    private let upperStackView = UIStackView()
    let leftNavLabel = UILabel()
    private let rightNavLabelStack = UIStackView()
    let rightUpperNavLabel = UILabel()
    let rightLowerNavLabel = UILabel()
    
    private let lowerStackView = UIStackView()
    let leftPartView = UILabel()
    let middlePartView = UILabel()
    let rightPartView = UILabel()
    
    private let timeFrameStackView = UIStackView()
    let oneMinuteButton = UIButton()
    let fiveMinutesButton = UIButton()
    let fifteenMinutesButton = UIButton()
    let oneHourButton = UIButton()
    let fourHours = UIButton()
    let oneDay = UIButton()
    
    private let buttonHeight = CGFloat(20)

    init(viewController: ChartViewController) {
        self.viewController = viewController
    }
    
    @objc func timeFrameButtonPressed(sender: UIButton) {
        guard let label = sender.titleLabel?.text else { return }
        viewController.timeFrame = label
        ColorManager.setBackgroundForButton(buttonNames: [oneMinuteButton, fiveMinutesButton, fifteenMinutesButton, oneHourButton, fourHours, oneDay], timeFrame: viewController.timeFrame)
        viewController.changeTimeFrame()
    }
    
    private func setupLabel(_ label: UILabel, text: String, textAlign: NSTextAlignment = .center, numberOfLines: Int) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.text = text
        label.textAlignment = textAlign
        label.numberOfLines = numberOfLines
    }
    
    private func setupStackView(_ stackView: UIStackView, axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution = .fillEqually) {
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.backgroundColor = .clear
    }
    
    private func setupButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    func loadViewComponents() {
        viewController.navigationItem.titleView = upperStackView
        
        setupLabel(leftNavLabel, text: "\(viewController.symbol)", textAlign: .left, numberOfLines: 1)
        setupLabel(rightUpperNavLabel, text: "\(viewController.closePrice)", numberOfLines: 1)
        setupLabel(rightLowerNavLabel, text: "\(viewController.priceChangePercent)", numberOfLines: 1)
        
        rightNavLabelStack.addArrangedSubview(rightUpperNavLabel)
        rightNavLabelStack.addArrangedSubview(rightLowerNavLabel)
        
        setupStackView(rightNavLabelStack, axis: .vertical, spacing: 1.0)
        setupStackView(upperStackView, axis: .horizontal, spacing: 5.0)
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        upperStackView.addArrangedSubview(leftNavLabel)
        upperStackView.addArrangedSubview(rightNavLabelStack)

        setupLabel(leftPartView, text: "24h volume\n\(viewController.volume24h)", numberOfLines: 2)
        setupLabel(middlePartView, text: "max: \(viewController.maxPrice)\nmin: \(viewController.minPrice)", numberOfLines: 2)
        setupLabel(rightPartView, text: "funding: \(viewController.fundingRate)%\nnext:\(viewController.nextFundingTime)", numberOfLines: 2)
        
        setupStackView(lowerStackView, axis: .horizontal, spacing: 5.0)
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        lowerStackView.addArrangedSubview(leftPartView)
        lowerStackView.addArrangedSubview(middlePartView)
        lowerStackView.addArrangedSubview(rightPartView)
        
        viewController.view.addSubview(lowerStackView)

        lowerStackView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 3).isActive = true
        lowerStackView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -3).isActive = true
        lowerStackView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor).isActive = true
        lowerStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        setupButton(oneMinuteButton, title: "1m")
        setupButton(fiveMinutesButton, title: "5m")
        setupButton(fifteenMinutesButton, title: "15m")
        setupButton(oneHourButton, title: "1h")
        setupButton(fourHours, title: "4h")
        setupButton(oneDay, title: "1d")
        
        setupStackView(timeFrameStackView, axis: .horizontal, spacing: 5.0)
        
        timeFrameStackView.addArrangedSubview(oneMinuteButton)
        timeFrameStackView.addArrangedSubview(fiveMinutesButton)
        timeFrameStackView.addArrangedSubview(fifteenMinutesButton)
        timeFrameStackView.addArrangedSubview(oneHourButton)
        timeFrameStackView.addArrangedSubview(fourHours)
        timeFrameStackView.addArrangedSubview(oneDay)

        viewController.view.addSubview(timeFrameStackView)
        
        timeFrameStackView.translatesAutoresizingMaskIntoConstraints = false
        timeFrameStackView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 5).isActive = true
        timeFrameStackView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -5).isActive = true
        timeFrameStackView.topAnchor.constraint(equalTo: lowerStackView.bottomAnchor).isActive = true
        timeFrameStackView.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        oneMinuteButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fiveMinutesButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fifteenMinutesButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        oneHourButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fourHours.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        oneDay.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        
        viewController.view.addSubview(viewController.lightWeightChartView)
        
        NSLayoutConstraint.activate([
            viewController.lightWeightChartView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
            viewController.lightWeightChartView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
            viewController.lightWeightChartView.topAnchor.constraint(equalTo: timeFrameStackView.bottomAnchor),
            viewController.lightWeightChartView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
