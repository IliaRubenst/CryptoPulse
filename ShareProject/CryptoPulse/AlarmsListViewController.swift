//
//  AlarmsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 21.09.2023.
//

import UIKit

class AlarmsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var filtredAlarms: [AlarmModel] = []
    var accounts = [Account]()
    var dbManager = DataBaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let defaults = DataLoader(keys: "savedAlarms")
//        defaults.loadUserSymbols()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        dbManager.performRequestDB()
        updateData()
        tableView.reloadData()
        for alarm in AlarmModelsArray.alarms {
            print(alarm)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        for alarm in AlarmModelsArray.alarms {
//            dbManager.updateDBData(alarmModel: alarm, change: alarm.id)
//        }
    }
    
    func setupUI() {
        configureNavButtons()
        configureSearchBar()
        configureTableView()
        configureGestureRecogniser()
        setupKeyboardDoneButton()
    }
    
    func updateData() {
        filtredAlarms = AlarmModelsArray.alarms
    }
    
    func configureNavButtons() {
        let eraseList = UIBarButtonItem(image: UIImage(systemName: "trash")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(removeAlarmsFromList))
        let addAlarm = UIBarButtonItem(image: UIImage(systemName: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(addAlarm))
        
        navigationItem.leftBarButtonItem = eraseList
        navigationItem.rightBarButtonItem = addAlarm
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        
        self.view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)])
    }
    
    func configureTableView() {
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: AlarmTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95),
            tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)])
    }
    
    func configureGestureRecogniser() {
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecogniser.delegate = self
        view.addGestureRecognizer(gestureRecogniser)
    }
    
    func setupKeyboardDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        self.searchBar.inputAccessoryView = toolBar
    }
    
    
    @objc func hideKeyboard(sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filtredAlarms = AlarmModelsArray.alarms.filter { $0.symbol.contains(searchText.uppercased()) }
            tableView.reloadData()
        } else {
            filtredAlarms = AlarmModelsArray.alarms
            tableView.reloadData()
        }
    }
    
    @objc func addAlarm() {
        let vc = AddAlarmViewController()
        vc.openedAlarmsList = self
        
        present(vc, animated: true)
    }
    
    @objc func removeAlarmsFromList() {
        let ac = UIAlertController(title: "Очистить уведомления", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Все", style: .destructive) { [weak self] _ in
            AlarmModelsArray.alarms.removeAll()
            self?.updateData()
            self?.tableView.reloadData()

            
//            let defaults = DataLoader(keys: "savedAlarms")
//            defaults.saveData()
        })
        ac.addAction(UIAlertAction(title: "Не активные", style: .default, handler: { [weak self] _ in
            let activeAlarms = AlarmModelsArray.alarms.filter({ $0.isActive })
            AlarmModelsArray.alarms = activeAlarms
            self?.updateData()
            self?.tableView.reloadData()
            
//            let defaults = DataLoader(keys: "savedAlarms")
//            defaults.saveData()
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(ac, animated: true)
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredAlarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier, for: indexPath) as? AlarmTableViewCell else { fatalError("Fatal error in AlarmVC CellForRow Method") }
        
        let item = filtredAlarms[indexPath.item]
        
        cell.tickerLabel.text = "\(item.symbol)"
        cell.dateLabel.text = "\(item.date)"
        cell.priceLabel.text = "Цена: \(item.alarmPrice)"
        cell.statusLabel.text = item.isActive ? "Активен" : "Не активен"
        
       return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailData") as? DetailViewController {
            detailVC.symbol = filtredAlarms[indexPath.item].symbol
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toggleAction = self.toggleStatusAction(rowIndexPathAt: indexPath)
        let deleteAction = self.deleteRowAction(rowIndexPathAt: indexPath)
        let editAlarmAction = self.editAlarmAction(rowIndexPathAt: indexPath)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAlarmAction, toggleAction])
        
        return swipeActions
    }
    
    func deleteRowAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let self = self else { return }
            
            let itemToRemoveID = filtredAlarms[indexPath.item].id
            filtredAlarms.remove(at: indexPath.item)
            deleteItemFromStaticAlarms(id: itemToRemoveID)
            dbManager.removeDBData(remove: itemToRemoveID)
            
//            let defaults = DataLoader(keys: "savedAlarms")
//            defaults.saveData()
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash")
        
        
        return action
    }
    
    func deleteItemFromStaticAlarms(id: Int) {
        for (index, item) in AlarmModelsArray.alarms.enumerated() {
            if item.id == id {
                AlarmModelsArray.alarms.remove(at: index)
            }
        }
    }
    
    func toggleStatusAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Переключить") { [weak self] _, _, _ in
            
            AlarmModelsArray.alarms[indexPath.item].isActive.toggle()
            self?.filtredAlarms[indexPath.item].isActive.toggle()
            
//            let defaults = DataLoader(keys: "savedAlarms")
//            defaults.saveData()
            for alarm in AlarmModelsArray.alarms {
                self?.dbManager.updateDBData(alarmModel: alarm, change: alarm.id)
            }
            
            self?.tableView.reloadData()
        }
        
        switch filtredAlarms[indexPath.item].isActive {
        case true:
            action.image = UIImage(systemName: "pause")
            action.backgroundColor = .systemGray
        case false:
            action.image = UIImage(systemName: "play")
            action.backgroundColor = .systemGreen
        }
        
        return action
    }
    
    func editAlarmAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Редкатировать") { [weak self] _, _, _ in
            guard let self = self else { return }
            
            let alarm = filtredAlarms[indexPath.item]
            
            let alarmID = alarm.id
            let alarmSymbol = alarm.symbol
            let alarmPrice = alarm.alarmPrice
            
//            let symbolModelForAlarm = SymbolsArray.symbols.filter { $0.symbol == alarmSymbol }
//            let currentSymbolPrice = symbolModelForAlarm.first?.markPrice
            
            let addAlarmVC = AddAlarmViewController()
            
            addAlarmVC.state = .editAlarm
            
            addAlarmVC.alarmID = alarmID
            addAlarmVC.symbol = alarmSymbol
//            addAlarmVC.closePrice = currentSymbolPrice
            addAlarmVC.alarmPrice = alarmPrice
            addAlarmVC.openedAlarmsList = self
            
            present(addAlarmVC, animated: true)
        }
        
        action.backgroundColor = .systemOrange
        action.image = UIImage(systemName: "pencil")
        
        return action
    }
    
    @objc func printResponse() {
        for account in AlarmModelsArray.alarms {
            print(account)
        }
    }
    
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Accessory path =", indexPath)
        
        let ownerCell = tableView.cellForRow(at: indexPath)
        print("Cell title =", ownerCell?.textLabel?.text ?? "nil")
    }*/
    
    
    
}
