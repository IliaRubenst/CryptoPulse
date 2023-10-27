//
//  AddAlarmViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 27.09.2023.
//

import UIKit

enum AddAlarmState {
    case newAlarm
    case editAlarm
}

class AddAlarmViewController: UIViewController, UITextFieldDelegate, WebSocketManagerDelegate {
    
    var state: AddAlarmState = .newAlarm
    
    var alarmID: Int?
    var symbol: String?
    var closePrice: String?
    var alarmPrice: Double?
    
    
    var webSocketManager: WebSocketManager! = nil
    var openedChart: DetailViewController? = nil
    var openedAlarmsList: AlarmsListViewController? = nil
    var dbManager: DataBaseManager! = nil
    var alarmManager: AlarmManager! = nil
    var chartManager: ChartManager! = nil
    var candleStickDataManager: CandleStickDataManager! = nil
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Уведомление"
        label.font = UIFont.systemFont(ofSize: 22)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.contentMode = .scaleToFill
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var symbolButton: TwoLabelsButton = {
        let button = TwoLabelsButton()
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white
        button.rightLabel.textColor = .white
        return button
    }()
    
    var priceButton: LabelTextFiledButton = {
        let button = LabelTextFiledButton()
        
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white       
        
        return button
    }()
    
    var colorButton: LabelColorButton = {
        let button = LabelColorButton()
        
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        
        button.leftLabel.textColor = .white
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbManager = DataBaseManager()
        candleStickDataManager = CandleStickDataManager()
        chartManager = ChartManager(delegate: openedChart!, symbol: openedChart!.symbol, timeFrame: openedChart!.timeFrame, candleStickDataManager: candleStickDataManager)
        alarmManager = AlarmManager(detailViewController: openedChart!, chartManager: chartManager)
        setupUI()
        updateUI()
        setupKeyboardDoneButton()
        configureButtons()
        openWebSocket()
    }
    
    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([titleLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([dismissButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)])
        
        NSLayoutConstraint.activate([saveButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),])
        
        NSLayoutConstraint.activate([mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                                     mainStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     mainStack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     ])
        
        NSLayoutConstraint.activate([symbolButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     symbolButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     symbolButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([priceButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     priceButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     priceButton.heightAnchor.constraint(equalToConstant: 50)])
        
        NSLayoutConstraint.activate([colorButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                                     colorButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                                     colorButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let webSocketManager {
            webSocketManager.close()
        }
    }
    
    func openWebSocket() {
        guard let symbol else { return }
        webSocketManager = WebSocketManager()
        webSocketManager.delegate = self
        webSocketManager.actualState = .individualSymbolTickerStreams
        
        webSocketManager.webSocketConnect(symbol: symbol, timeFrame: "1m")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if alarmPrice == nil {
            guard let closePrice else { return }
            priceButton.textField.text = closePrice
        }
    }
    
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {
        closePrice = dataModel.closePrice
        updateTwoLabelButtonUI()
    }
    
    
    
    func setupKeyboardDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        priceButton.textField.inputAccessoryView = toolBar
    }
    
    @objc func didTapDone() {
        view.endEditing(true)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        
        view.addSubview(saveButton)
        view.addSubview(mainStack)
        
        mainStack.addArrangedSubview(symbolButton)
        mainStack.addArrangedSubview(priceButton)
        mainStack.addArrangedSubview(colorButton)
    }
    
    func updateUI() {
        updateTwoLabelButtonUI()
        
        if let alarmPrice {
            priceButton.textField.text = "\(alarmPrice)"
        } else {
            priceButton.textField.text = "0.00"
        }
    }
    
    func updateTwoLabelButtonUI() {
        var leftLabel: String
        var rightLabel: String
        
        if let symbol, let closePrice {
            leftLabel = symbol
            rightLabel = closePrice
        } else if let symbol {
            leftLabel = symbol
            rightLabel = "Подключение..."
        } else {
            leftLabel = "Инструмент"
            rightLabel = ">"
        }
        
        let viewModel = TwoLabelsButtonViewModel(leftLabel: leftLabel, rightLabel: rightLabel)
        symbolButton.configure(with: viewModel)
    }
    
    func configureButtons() {
        priceButton.textField.delegate = self
        symbolButton.addTarget(self, action: #selector(openSymbolsList), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveAlarm), for: .touchUpInside)
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    @objc func openSymbolsList() {
        let table = SymbolsListController()
        table.senderState = .alarmsView
        table.addAlarmVC = self
        
        present(table, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let formattedText = text.replacingOccurrences(of: ",", with: ".")
        let alarmPrice = Double(formattedText)
        self.alarmPrice = alarmPrice
    }
    
    @objc func saveAlarm() {
        didTapDone()
        
        guard let closePrice,
              let symbol,
              let doubleClosePrice = Double(closePrice),
              let alarmPrice else { return }
        
        switch state {
        case .newAlarm:
            alarmManager.addAlarmForCurrentPrice(alarmPrice: alarmPrice, closePrice: doubleClosePrice, symbol: symbol)
            let id = Int.random(in: 0...999999999)
            let idString = String(id)
            if let openedChart {
                openedChart.alarmManager?.setupAlarmLine(alarmPrice, id: idString)
            }
            
        case .editAlarm:
            guard let alarmID else { return }
            guard let alarmToEdit = AlarmModelsArray.alarms.filter({ $0.id == alarmID }).first else { return }
            
            guard let index = AlarmModelsArray.alarms.firstIndex(of: alarmToEdit) else { return }
            AlarmModelsArray.alarms[index].alarmPrice = alarmPrice
            dbManager.updateDBData(alarmModel: alarmToEdit, change: alarmID)
        }
        
//        let defaults = DataLoader(keys: "savedAlarms")
//        defaults.saveData()
        
        if let openedAlarmsList {
            openedAlarmsList.updateData()
            openedAlarmsList.tableView.reloadData()
        }
        
        dismissSelf()
    }
}
