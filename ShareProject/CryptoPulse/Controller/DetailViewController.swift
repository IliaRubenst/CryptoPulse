//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit
import Foundation
import LightweightCharts

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        return Set(self).isSubset(of: nums)
    }
}

private enum Constants {
    static let backImageName = "chevron.backward"
    static let bellImageName = "bell"
    static let cameraImageName = "camera"
}

class DetailViewController: UIViewController {
    var lightWeightChartView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var helper: DetailViewHelper!
    var webSocketManagers = [WebSocketManager]()
    var chartManager: ChartManager!
    var dbManager = DataBaseManager()
    var data = [CandlestickData]()
    var currentCandelModel: CurrentCandleModel!
    var alarmManager: AlarmManager?

    var price: String = ""
    
    // data from CurrentCandleData
    var closePrice: Double = 0
    
    // data from MarkPriceStream
    var symbol: String = ""
    var fundingRate: String = "0.0"
    var nextFundingTime: String = "00:00:00"
    
    //data from IndividualSymbolTickerStreams
    var priceChangePercent: String = "0.0"
    var volume24h: String = "0.0"
    var maxPrice: String = "0.0"
    var minPrice: String = "0.0"

    
    var isKlineClose = false
    var timeFrame = "15m"
    
    override func loadView() {
        super.loadView()

        helper = DetailViewHelper(viewController: self)
        helper.loadViewComponents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()
        configureNavBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupChartManager()
        alarmManager = AlarmManager(detailViewController: self, chartManager: chartManager)
        setupButtonBackgrounds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        for view in self.lightWeightChartView.subviews {
            view.removeFromSuperview()
        }
        
        terminateWebSocketsManagers()
        clearChartManager()
        clearAlarmManager()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarm), name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarmForSelectedPrice), name: NSNotification.Name(rawValue: "button2Pressed"), object: nil)
    }
    
    @objc func addAlarmForSelectedPrice() {
            alarmManager?.addAlarmForSelectedPrice(alarmPrice: chartManager.currentCursorPrice, closePrice: closePrice, symbol: symbol)
    }
    
    @objc func addAlarm() {
        alarmManager?.addAlarm(symbol: symbol, closePrice: closePrice, openedChart: self)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configureNavBarButtons() {
        navigationItem.leftBarButtonItem = createBarButtonItem(imageName: Constants.backImageName, action: #selector(backTapped))
        
        let setAlarmButton = createBarButtonItem(imageName: Constants.bellImageName, action: #selector(addAlarm))
        let screenShotButton = createBarButtonItem(imageName: Constants.cameraImageName, action: #selector(takeScreenShot))
        
        navigationItem.rightBarButtonItems = [setAlarmButton, screenShotButton]
    }
    
    private func createBarButtonItem(imageName: String, action: Selector) -> UIBarButtonItem {
        let buttonImage = UIImage(systemName: imageName)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: action)
    }
    
    private func setupChartManager() {
        chartManager = ChartManager(delegate: self, symbol: symbol, timeFrame: timeFrame)
        startChartManager()
    }
    
    private func setupButtonBackgrounds() {
        ColorManager.setBackgroundForButton(buttonNames: [helper.oneMinuteButton, helper.fiveMinutesButton, helper.fifteenMinutesButton, helper.oneHourButton, helper.fourHours, helper.oneDay], timeFrame: timeFrame)
    }
    
    func startChartManager() {
//        chartManager = nil // Не уверен, что это необходимо, но есть сомнения насчет того, сколько инстансов чартменеджера мы создаем, поэтому перед инициализацией нового, я решил на всякий случай явно грохать старого.
        self.chartManager?.data.removeAll()
        self.chartManager = nil
        self.chartManager = ChartManager(delegate: self, symbol: symbol, timeFrame: timeFrame)
        chartManager.fetchRequest(symbol: symbol, timeFrame: timeFrame)
        chartManager.setupChart()
        
        chartManager.setupSubscription()
    }
    
    func startWebSocketManagers() {
        terminateWebSocketsManagers()
        
        for state in State.allCases {
            let manager = WebSocketManager()
            manager.delegate = self
            manager.actualState = state
            manager.webSocketConnect(symbol: symbol, timeFrame: timeFrame)

            webSocketManagers.append(manager)
        }
    }
    
    private func terminateWebSocketsManagers() {
        webSocketManagers.forEach { $0.close() }
        webSocketManagers = []
    }
    
    private func clearChartManager() {
        chartManager.data.removeAll()
        chartManager = nil
    }
    
    private func clearAlarmManager() {
        alarmManager = nil
    }
        
    @objc func takeScreenShot() {
        let screenShot = lightWeightChartView.makeScreenshot()
        guard let imageToData = screenShot.jpegData(compressionQuality: 1) else {
            print("Снова ошибка")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [imageToData], applicationActivities: [])
        present(activityVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - WebSocketManagerDelegate Methods
extension DetailViewController: WebSocketManagerDelegate {
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        closePrice = Double(candleModel.closePrice)!
        isKlineClose = candleModel.isKlineClose
        currentCandelModel = candleModel

        chartManager.tick()
        alarmManager?.alarmObserver(for: symbol, equal: closePrice)
        ColorManager.percentText(priceChangePercent: priceChangePercent, rightLowerNavLabel: helper.rightLowerNavLabel)
        
        helper.rightLowerNavLabel.text = "\(priceChangePercent)%"
    }
    
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {
        symbol = dataModel.symbol
        let fundingrRateDouble = Double(dataModel.fundingRate)! * 100
        fundingRate = String(format: "%.3f", fundingrRateDouble)
        nextFundingTime = dataModel.timeTodateFormat(nextFindingTime: dataModel.nextFundingTime)
        helper.rightPartView.text = "funding: \(fundingRate)%\nnext:\(nextFundingTime)"
    }
    
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {
        priceChangePercent = dataModel.priceChangePercent
        
        maxPrice = dataModel.highPrice
        minPrice = dataModel.lowPrice
        volume24h = dataModel.volumeQuote
        
        helper.rightUpperNavLabel.text = "\(closePrice)\n\(priceChangePercent)%"
        helper.leftPartView.text = "24h volume\n\(volume24h)"
        helper.middlePartView.text = "max: \(maxPrice)\nmin: \(minPrice)"
    }
}


extension UIView {
    func makeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}

final class DetailViewHelper {
    unowned var viewController: DetailViewController
    
    let upperStackView = UIStackView()
    let leftNavLabel = UILabel()
    let rightNavLabelStack = UIStackView()
    let rightUpperNavLabel = UILabel()
    let rightLowerNavLabel = UILabel()
    
    let lowerStackView = UIStackView()
    let leftPartView = UILabel()
    let middlePartView = UILabel()
    let rightPartView = UILabel()
    
    let timeFrameStackView = UIStackView()
    let oneMinuteButton = UIButton()
    let fiveMinutesButton = UIButton()
    let fifteenMinutesButton = UIButton()
    let oneHourButton = UIButton()
    let fourHours = UIButton()
    let oneDay = UIButton()
    
    let buttonHeight = CGFloat(20)

    init(viewController: DetailViewController) {
        self.viewController = viewController
    }
    
    @objc func timeFrameButtonPressed(sender: UIButton) {
        for manager in viewController.webSocketManagers {
            manager.close()
        }
        
        guard let label = sender.titleLabel?.text else { return }
        viewController.timeFrame = label
        ColorManager.setBackgroundForButton(buttonNames: [oneMinuteButton, fiveMinutesButton, fifteenMinutesButton, oneHourButton, fourHours, oneDay], timeFrame: viewController.timeFrame)
        
        for view in viewController.lightWeightChartView.subviews {
            view.removeFromSuperview()
        }
        viewController.startChartManager()
    }
    
    private func setupLabel(_ label: UILabel, text: String, textAlign: NSTextAlignment = .center) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.text = text
        label.textAlignment = textAlign
    }
    
    private func setupStackView(_ stackView: UIStackView, axis: NSLayoutConstraint.Axis, spacing: CGFloat, distribution: UIStackView.Distribution = .fillEqually) {
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.backgroundColor = .clear
    }
    
    func setupButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    func loadViewComponents() {
        viewController.navigationItem.titleView = upperStackView
        
        setupLabel(leftNavLabel, text: "\(viewController.symbol)", textAlign: .left)
        setupLabel(rightUpperNavLabel, text: "\(viewController.closePrice)")
        setupLabel(rightLowerNavLabel, text: "\(viewController.priceChangePercent)")
        
        rightNavLabelStack.addArrangedSubview(rightUpperNavLabel)
        rightNavLabelStack.addArrangedSubview(rightLowerNavLabel)
        
        setupStackView(rightNavLabelStack, axis: .vertical, spacing: 1.0)
        setupStackView(upperStackView, axis: .horizontal, spacing: 5.0)
        upperStackView.translatesAutoresizingMaskIntoConstraints = false

        upperStackView.addArrangedSubview(leftNavLabel)
        upperStackView.addArrangedSubview(rightNavLabelStack)

        setupLabel(leftPartView, text: "24h volume\n\(viewController.volume24h)")
        leftPartView.numberOfLines = 2
        
        setupLabel(middlePartView, text: "max: \(viewController.maxPrice)\nmin: \(viewController.minPrice)")
        middlePartView.numberOfLines = 2

        setupLabel(rightPartView, text: "funding: \(viewController.fundingRate)%\nnext:\(viewController.nextFundingTime)")
        rightPartView.numberOfLines = 2

        
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


