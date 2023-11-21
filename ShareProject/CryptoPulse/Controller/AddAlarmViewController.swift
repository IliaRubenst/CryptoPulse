//
//  AddAlarmViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 27.09.2023.
//

import UIKit
import LightweightCharts

enum AddAlarmState {
    case newAlarm
    case editAlarm
}

class AddAlarmViewController: UIViewController, UITextFieldDelegate, WebSocketManagerDelegate {
    
    var state: AddAlarmState = .newAlarm
    
    var alarmID: String?
    var symbol: String?
    var closePrice: String?
    var alarmPrice: Double?
    
    var webSocketManager: WebSocketManager! = nil
    weak var openedChart: ChartViewController? = nil
    var openedAlarmsList: AlarmsListViewController? = nil
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create alarm"
        label.font = UIFont.systemFont(ofSize: 22)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
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
    
    var colorButton: LabelColorButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorButton = LabelColorButton(alarmColor: ColorManager.setAlarmColor(alarmID: alarmID ?? "BTCUSDT") ?? "#f00")
        colorButton.layer.cornerRadius = 10
        colorButton.backgroundColor = .systemBlue
        colorButton.leftLabel.textColor = .white

        mainStack.addArrangedSubview(colorButton)
        
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
            rightLabel = "Connecting..."
        } else {
            leftLabel = "Symbol"
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
            let alarmManager = AlarmManager(chartManager: nil)
            alarmManager.addAlarmAtSetPrice(alarmPrice: alarmPrice, closePrice: doubleClosePrice, symbol: symbol)
            
            let id = Int.random(in: 0...999999999)
            let idString = String(id)
            let alarmColor = "#f00"
            
            if let openedChart {
                openedChart.alarmManager?.setupAlarmLine(alarmPrice, id: idString, color: ChartColor(rawValue: alarmColor))
            }
            
        case .editAlarm:
            guard let alarmID else { return }
            guard let alarmToEdit = AlarmModelsArray.alarms.filter({ $0.alarmID == alarmID }).first else { return }
            let color = colorButton.colorWell.selectedColor
            print(color)
            guard let colorHex = color?.hexString else { return }
            print(colorHex)
            guard let index = AlarmModelsArray.alarms.firstIndex(of: alarmToEdit) else { return }
            AlarmModelsArray.alarms[index].alarmPrice = alarmPrice
            AlarmModelsArray.alarms[index].isAlarmUpper = AlarmManager.isAlarmUpper(alarmPrice: alarmPrice, closePrice: doubleClosePrice)
            AlarmModelsArray.alarms[index].alarmColor = colorHex
            let editedAlarm = AlarmModelsArray.alarms[index]
            
            let dbManager = DataBaseManager()
            dbManager.updateDBData(alarmModel: editedAlarm, change: alarmID)
        }
        
//        let defaults = DataLoader(keys: "savedAlarms")
//        defaults.saveData()
        
        if let openedAlarmsList {
            openedAlarmsList.updateData()
            openedAlarmsList.tableView.reloadData()
        }
        
        dismissSelf()
    }
    
    deinit {
        print("AddAlarmViewController деинициализрован")
    }
}
