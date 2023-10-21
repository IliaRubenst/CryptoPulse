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

class DetailViewController: UIViewController, WebSocketManagerDelegate {
    var lightWeightChartView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    var webSocketManagers = [WebSocketManager]()
    var chartManager: ChartManager!
    var dbManager = DataBaseManager()
//    var candles = [PreviousCandlesModel]()
    var data = [CandlestickData]()
    var currentCandelModel: CurrentCandleModel!

    
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
    var id = 0
    
    var isKlineClose = false
    var alarm: Double = 0
    var isAlertShowing: Bool = false
    
    var timeFrame = "15m"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let defaults = DataLoader(keys: "savedAlarms")
//        defaults.loadUserSymbols()
        
        configureNavBarButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarm), name: NSNotification.Name(rawValue: "button1Pressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addAlarmForSelectedPrice), name: NSNotification.Name(rawValue: "button2Pressed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startChartManager()
        setBackgroundForButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for manager in webSocketManagers {
            manager.close()
        }
        
        chartManager.data.removeAll()
//        chartManager = nil // Не уверен, что это необходимо, но есть сомнения насчет того, сколько инстансов чартменеджера мы создаем, поэтому перед инициализацией нового, я решил на всякий случай явно грохать старого.
        
    }
    
    @objc func backTapped() {
    self.navigationController?.popViewController(animated: true)
    }
    
    func configureNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backTapped))
        let setAlarmButton = UIBarButtonItem(image: UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(addAlarm))
        let screenShotButton = UIBarButtonItem(image: UIImage(systemName: "camera")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(takeScreenShot))
        navigationItem.rightBarButtonItems = [setAlarmButton, screenShotButton]
    }
    
   func setBackgroundForButton() {
        let names = [oneMinuteButton, fiveMinutesButton, fifteenMinutesButton, oneHourButton, fourHours, oneDay]
        for name in names {
            if name.titleLabel?.text == timeFrame {
                name.backgroundColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
            } else {
                name.backgroundColor = .clear
            }
        }

    }

    func setupAlarmLines() {
//        print(AlarmModelsArray.alarms.count)
        for alarm in AlarmModelsArray.alarms {
            chartManager.setupAlarmLine(alarm.alarmPrice, id: String(alarm.id))
        }
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        closePrice = Double(candleModel.closePrice)!
        isKlineClose = candleModel.isKlineClose
        currentCandelModel = candleModel
        
        chartManager.tick()
        alarmObserver()
        
        ColorManager.percentText(priceChangePercent: priceChangePercent, rightLowerNavLabel: rightLowerNavLabel)
        
        rightLowerNavLabel.text = "\(priceChangePercent)%"
    }
    
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {
        symbol = dataModel.symbol
        let fundingrRateDouble = Double(dataModel.fundingRate)! * 100
        fundingRate = String(format: "%.3f", fundingrRateDouble)
        nextFundingTime = dataModel.timeTodateFormat(nextFindingTime: dataModel.nextFundingTime)
        rightPartView.text = "funding: \(fundingRate)%\nnext:\(nextFundingTime)"
    }
    
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {
        priceChangePercent = dataModel.priceChangePercent
        
        maxPrice = dataModel.highPrice
        minPrice = dataModel.lowPrice
        volume24h = dataModel.volumeQuote
        
        rightUpperNavLabel.text = "\(closePrice)\n\(priceChangePercent)%"
        leftPartView.text = "24h volume\n\(volume24h)"
        middlePartView.text = "max: \(maxPrice)\nmin: \(minPrice)"
    }
    
    
    func alarmObserver() {
        let upToDown = "сверху вниз"
        let downToUp = "снизу вверх"
        
        var telegramAlram = TelegramNotifications()
        
        for (index, state) in AlarmModelsArray.alarms.enumerated() where state.isActive {
            if state.isAlarmUpper {
                if closePrice >= state.alarmPrice && !isAlertShowing && symbol == state.symbol {
                    telegramAlram.message = "Цена \(state.symbol) пересекла \(state.alarmPrice) \(downToUp)"
//                    telegramAlram.postRequest()
                    
                    let ac = UIAlertController(title: "Alarm for \(state.symbol)", message: "The price crossed \(state.alarmPrice) \(downToUp) ", preferredStyle: .alert)
                    isAlertShowing = true
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.isAlertShowing = false
                    })
                    present(ac, animated: true)
                    
//                    chartManager.removeAlarmLine(index)
//                    AlarmModelsArray.alarms.remove(at: index)
                    AlarmModelsArray.alarms[index].isActive = false
//                    let defaults = DataLoader(keys: "savedAlarms")
//                    defaults.saveData()
                }
            } else {
                if closePrice <= state.alarmPrice && !isAlertShowing && symbol == state.symbol {
                    telegramAlram.message = "Цена \(state.symbol) пересекла \(state.alarmPrice) \(upToDown)"
//                    telegramAlram.postRequest()
                    
                    let ac = UIAlertController(title: "Alarm for \(state.symbol)", message: "The price crossed \(state.alarmPrice) \(upToDown) ", preferredStyle: .alert)
                    isAlertShowing = true
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.isAlertShowing = false
                    })
                    present(ac, animated: true)
//                    chartManager.removeAlarmLine(index)
//                    AlarmModelsArray.alarms.remove(at: index)
                    AlarmModelsArray.alarms[index].isActive = false
                    
//                    let defaults = DataLoader(keys: "savedAlarms")
//                    defaults.saveData()
                }
            }
//            for alarm in AlarmModelsArray.alarms {
//                dbManager.updateDBData(alarmModel: alarm, change: alarm.id)
//            }

        }
    }
    
    func startChartManager() {
        chartManager = nil // Не уверен, что это необходимо, но есть сомнения насчет того, сколько инстансов чартменеджера мы создаем, поэтому перед инициализацией нового, я решил на всякий случай явно грохать старого.
        
        chartManager = ChartManager(delegate: self, symbol: symbol, timeFrame: timeFrame)
        chartManager.fetchRequest(symbol: symbol, timeFrame: timeFrame)
        chartManager.setupChart()
        
        chartManager.setupSubscription()
    }
    
    func startWebSocketManagers() {
        for state in State.allCases {
            let manager = WebSocketManager()
            manager.delegate = self
            manager.actualState = state
            manager.webSocketConnect(symbol: symbol, timeFrame: timeFrame)

            webSocketManagers.append(manager)
        }
    }
    
    
    // может перенести два метода в AlarmManager?
    @objc func addAlarm() {
        // Заготовка
        let addAlarmVC = AddAlarmViewController()
        addAlarmVC.symbol = symbol
        addAlarmVC.closePrice = String(closePrice)
        addAlarmVC.symbolButton.isEnabled = false
        addAlarmVC.openedChart = self
        
        if let sheet = addAlarmVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(addAlarmVC, animated: true)
        
        /*let ac = UIAlertController(title: "Set alarm for \(symbol)", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "00.00"
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        ac.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let text = ac.textFields?[0].text else { return }
            if text != "" && text.isNumeric {
                self!.alarm = Double(text)!
                var isAlarmUpper = false
                if self!.alarm > self!.closePrice {
                    isAlarmUpper = true
                }
                self?.id = Int.random(in: 0...999999999)
                
                let currentDate = self?.convertCurrentDateToString()
                guard let unwrappedDate = currentDate else {
                    fatalError("Current date is nil")
                }
                
                let currentModel = AlarmModel(id: self!.id, symbol: self!.symbol, alarmPrice: self!.alarm, isAlarmUpper: isAlarmUpper, isActive: true, date: unwrappedDate)
                
                AlarmModelsArray.alarms.append(currentModel)
                self!.addAlarmtoModelDB(alarmModel: currentModel)
                
                let defaults = DataLoader(keys: "savedAlarms")
                defaults.saveData()

                self?.chartManager.setupAlarmLine(self!.alarm)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)*/
    }
    
    @objc func addAlarmForSelectedPrice() {
        guard let price = chartManager.currentCursorPrice else { return }
        alarm = price
        
        let isAlarmUpper = alarm > closePrice ? true : false

        id = Int.random(in: 0...999999999)
        let idString = String(id)
        let currentDate = convertCurrentDateToString()
        let currentModel = AlarmModel(id: id, symbol: symbol, alarmPrice: alarm, isAlarmUpper: isAlarmUpper, isActive: true, date: currentDate)

        dbManager.addAlarmtoModelDB(alarmModel: currentModel) { data, error  in
            if error == nil {
                AlarmModelsArray.alarms.removeAll()
                self.dbManager.performRequestDB { (data, error) in
                    if error == nil {
                    } else {
                        print("Не удалось получить данные из БД")
                    }
                }
            } else {
                print("Не удалось создать аларм в БД")
            }
        }
//        AlarmModelsArray.alarms.append(currentModel)
//        let defaults = DataLoader(keys: "savedAlarms")
//        defaults.saveData()
        
        chartManager.setupAlarmLine(alarm, id: idString)
    }
    
    override func loadView() {
        super.loadView()
        
        leftNavLabel.translatesAutoresizingMaskIntoConstraints = false
//        leftNavLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
        leftNavLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        leftNavLabel.font = .systemFont(ofSize: 13)
        leftNavLabel.text = "\(symbol)"
        leftNavLabel.textAlignment = .left
        
        rightUpperNavLabel.translatesAutoresizingMaskIntoConstraints = false
//        rightUpperNavLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
//        rightUpperNavLabel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        rightUpperNavLabel.font = .systemFont(ofSize: 13)
        rightUpperNavLabel.text = "\(closePrice)"
        rightUpperNavLabel.textAlignment = .center
        
        rightLowerNavLabel.translatesAutoresizingMaskIntoConstraints = false
//        rightLowerNavLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
//        rightLowerNavLabel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        rightLowerNavLabel.font = .systemFont(ofSize: 13)
        rightLowerNavLabel.text = "\(priceChangePercent)"
        rightLowerNavLabel.textAlignment = .center
        
        rightNavLabelStack.addArrangedSubview(rightUpperNavLabel)
        rightNavLabelStack.addArrangedSubview(rightLowerNavLabel)
        
        rightNavLabelStack.axis = .vertical
        rightNavLabelStack.distribution = .equalCentering
        rightNavLabelStack.alignment = .center
        rightNavLabelStack.backgroundColor = .clear
        rightNavLabelStack.spacing = 1.0
        
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        
        upperStackView.spacing = 5.0
        upperStackView.addArrangedSubview(leftNavLabel)
        upperStackView.addArrangedSubview(rightNavLabelStack)
        upperStackView.distribution = .fillEqually

        self.navigationItem.titleView = upperStackView
        
        leftPartView.translatesAutoresizingMaskIntoConstraints = false
//        leftPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
//        leftPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        leftPartView.font = .systemFont(ofSize: 13)
        leftPartView.numberOfLines = 2
        leftPartView.text = "24h volume\n\(volume24h)"
        leftPartView.textAlignment = .center

        middlePartView.translatesAutoresizingMaskIntoConstraints = false
//        middlePartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
//        middlePartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        middlePartView.font = .systemFont(ofSize: 13)
        middlePartView.numberOfLines = 2
        middlePartView.text = "max: \(maxPrice)\nmin: \(minPrice)"
        middlePartView.textAlignment = .center

        rightPartView.translatesAutoresizingMaskIntoConstraints = false
//        rightPartView.heightAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
//        rightPartView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3).isActive = true
        rightPartView.font = .systemFont(ofSize: 13)
        rightPartView.numberOfLines = 2
        rightPartView.text = "funding: \(fundingRate)%\nnext:\(nextFundingTime)"
        rightPartView.textAlignment = .center

        lowerStackView.axis = .horizontal
        lowerStackView.distribution = .fillEqually
        lowerStackView.alignment = .center
        lowerStackView.backgroundColor = .clear
        lowerStackView.spacing = 5.0
        
        lowerStackView.addArrangedSubview(leftPartView)
        lowerStackView.addArrangedSubview(middlePartView)
        lowerStackView.addArrangedSubview(rightPartView)
        
        self.view.addSubview(lowerStackView)
        
        lowerStackView.translatesAutoresizingMaskIntoConstraints = false
        lowerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 3).isActive = true
        lowerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -3).isActive = true
        lowerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        lowerStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let buttonHeight = CGFloat(20)
//        let buttonWidth = CGFloat(20)
        
        oneMinuteButton.setTitle("1m", for: .normal)
        oneMinuteButton.setTitleColor(.black, for: .normal)
        oneMinuteButton.titleLabel?.font = .systemFont(ofSize: 13)
        oneMinuteButton.layer.borderWidth = 1
        oneMinuteButton.layer.cornerRadius = 5
        oneMinuteButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        oneMinuteButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true

        fiveMinutesButton.setTitle("5m", for: .normal)
        fiveMinutesButton.setTitleColor(.black, for: .normal)
        fiveMinutesButton.titleLabel?.font = .systemFont(ofSize: 13)
        fiveMinutesButton.layer.borderWidth = 1
        fiveMinutesButton.layer.cornerRadius = 5
        fiveMinutesButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        fiveMinutesButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        fifteenMinutesButton.setTitle("15m", for: .normal)
        fifteenMinutesButton.setTitleColor(.black, for: .normal)
        fifteenMinutesButton.titleLabel?.font = .systemFont(ofSize: 13)
        fifteenMinutesButton.layer.borderWidth = 1
        fifteenMinutesButton.layer.cornerRadius = 5
        fifteenMinutesButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        fifteenMinutesButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        oneHourButton.setTitle("1h", for: .normal)
        oneHourButton.setTitleColor(.black, for: .normal)
        oneHourButton.titleLabel?.font = .systemFont(ofSize: 13)
        oneHourButton.layer.borderWidth = 1
        oneHourButton.layer.cornerRadius = 5
        oneHourButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        oneHourButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        fourHours.setTitle("4h", for: .normal)
        fourHours.setTitleColor(.black, for: .normal)
        fourHours.titleLabel?.font = .systemFont(ofSize: 13)
        fourHours.layer.borderWidth = 1
        fourHours.layer.cornerRadius = 5
        fourHours.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        fourHours.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        oneDay.setTitle("1d", for: .normal)
        oneDay.setTitleColor(.black, for: .normal)
        oneDay.titleLabel?.font = .systemFont(ofSize: 13)
        oneDay.layer.borderWidth = 1
        oneDay.layer.cornerRadius = 5
        oneDay.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        oneDay.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true

        timeFrameStackView.axis = .horizontal
        timeFrameStackView.distribution = .fillEqually
        timeFrameStackView.alignment = .center
        timeFrameStackView.backgroundColor = .clear
        timeFrameStackView.spacing = 2.0
        
        timeFrameStackView.addArrangedSubview(oneMinuteButton)
        timeFrameStackView.addArrangedSubview(fiveMinutesButton)
        timeFrameStackView.addArrangedSubview(fifteenMinutesButton)
        timeFrameStackView.addArrangedSubview(oneHourButton)
        timeFrameStackView.addArrangedSubview(fourHours)
        timeFrameStackView.addArrangedSubview(oneDay)

        self.view.addSubview(timeFrameStackView)
        
        timeFrameStackView.translatesAutoresizingMaskIntoConstraints = false
        timeFrameStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5).isActive = true
        timeFrameStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true
        timeFrameStackView.topAnchor.constraint(equalTo: lowerStackView.bottomAnchor).isActive = true
        timeFrameStackView.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        oneMinuteButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fiveMinutesButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fifteenMinutesButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        oneHourButton.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        fourHours.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        oneDay.addTarget(self, action: #selector(timeFrameButtonPressed(sender:)), for: .touchUpInside)
        
        view.addSubview(lightWeightChartView)
        
        NSLayoutConstraint.activate([
            lightWeightChartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            lightWeightChartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            lightWeightChartView.topAnchor.constraint(equalTo: timeFrameStackView.bottomAnchor),
            lightWeightChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func timeFrameButtonPressed(sender: UIButton) {
        for manager in webSocketManagers {
            manager.close()
        }
        
        guard let label = sender.titleLabel?.text else { return }
        timeFrame = label
        setBackgroundForButton()
        
        for view in self.lightWeightChartView.subviews {
            view.removeFromSuperview()
        }
        
        startChartManager()
    }
    
    func convertCurrentDateToString() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyy hh:mm"
        let now = df.string(from: Date())
        return now
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
}


extension UIView {
    func makeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}

