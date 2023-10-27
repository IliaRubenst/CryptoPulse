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
    
    var helper: DetailViewUI!
    var webSocketManagers = [WebSocketManager]()
    var chartManager: ChartManager!
    var dbManager = DataBaseManager()
    var data = [CandlestickData]()
    var currentCandelModel: CurrentCandleModel!
    var alarmManager: AlarmManager?
    var candleStickDataManager: CandleStickDataManager!

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
        
        view.backgroundColor = .systemBackground

        helper = DetailViewUI(viewController: self)
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
    
    func changeTimeFrame() {
        for view in self.lightWeightChartView.subviews {
            view.removeFromSuperview()
        }
        
        terminateWebSocketsManagers()
        clearChartManager()
        clearAlarmManager()
        
        setupChartManager()
        alarmManager = AlarmManager(detailViewController: self, chartManager: chartManager)
        setupButtonBackgrounds()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarm), name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarmForSelectedPrice), name: NSNotification.Name(rawValue: "button2Pressed"), object: nil)
    }
    
    @objc func addAlarmForSelectedPrice() {
        alarmManager?.addAlarmForSelectedPrice(alarmPrice: chartManager.currentCursorPrice!, closePrice: closePrice, symbol: symbol)
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
        candleStickDataManager = CandleStickDataManager() // потом перенести в отдельный метод
        chartManager = ChartManager(delegate: self, symbol: symbol, timeFrame: timeFrame, candleStickDataManager: candleStickDataManager)
        startChartManager()
    }
    
    private func setupButtonBackgrounds() {
        ColorManager.setBackgroundForButton(buttonNames: [helper.oneMinuteButton, helper.fiveMinutesButton, helper.fifteenMinutesButton, helper.oneHourButton, helper.fourHours, helper.oneDay], timeFrame: timeFrame)
    }
    
    private func startChartManager() {
        self.chartManager?.data.removeAll()
        self.chartManager = nil
        self.chartManager = ChartManager(delegate: self, symbol: symbol, timeFrame: timeFrame, candleStickDataManager: candleStickDataManager)
        chartManager.fetchCandlesData()
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




