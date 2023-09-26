//
//  AlarmsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 21.09.2023.
//

import UIKit

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    var cellIdentifier = "alarmCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eraseListButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeAlarmsFromList))
        navigationItem.rightBarButtonItem = eraseListButton
        
        //кнопки потом удалим, нужны для тестов
//        let getBDData = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(performRequestDB))
        let printBtn = UIBarButtonItem(image: UIImage(systemName: "printer")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(printResponse))
        navigationItem.leftBarButtonItems = [printBtn]
        
        // делаем get запрос на сервер для получения данных по алармам
        performRequestDB()
        
        let defaults = DataLoader(keys: "savedAlarms")
        defaults.loadUserSymbols()

        createTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func createTable() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(tableView)
    }
    
    @objc func removeAlarmsFromList() {
        AlarmModelsArray.alarms.removeAll()
        tableView.reloadData()
//        AlarmModelsArray.alarmaLine.removeAll()
        
        let defaults = DataLoader(keys: "savedAlarms")
        defaults.saveData()
        
//        defaults.keys = "savedLines"
//        defaults.saveData()
    }
    
    //MARK: - UITableViewDataSource
    /*func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmModelsArray.alarms.count
        /*switch section {
        case 0:
            return 3
        case 1:
            return 5
        case 2:
            return 8
        default:
            break
        }
        return 0*/
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var content = UIListContentConfiguration.cell()
        
        let item = AlarmModelsArray.alarms[indexPath.item]
        content.text = "\(item.symbol) - \(item.alarmPrice). isActive: \(item.isActive)"
        cell.contentConfiguration = content
        
        /*cell.accessoryType = .detailButton
        
        switch indexPath.section {
        case 0:
            cell.backgroundColor = UIColor.white
        case 1:
            cell.backgroundColor = UIColor.blue
        case 2:
            cell.backgroundColor = UIColor.red
        default:
            break
        }*/
        
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AlarmModelsArray.alarms.remove(at: indexPath.item)
            
            let defaults = DataLoader(keys: "savedAlarms")
            defaults.saveData()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func performRequestDB() {
        if let url = URL(string: "http://127.0.0.1:8000/api/account/") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    parseJSONDB(DBData: safeData)
                }
            }
            task.resume()
            print("Make \(request.httpMethod!) request to:\(url)")
        }
    }
    
    func parseJSONDB(DBData: Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode([Account].self, from: DBData)
            for data in decodedData {
                AccountModel.accounts.append(Account(id: data.id,
                                                     symbol: data.symbol,
                                                     alarmPrice: data.alarmPrice,
                                                     isAlarmUpper: data.isAlarmUpper,
                                                     isActive: data.isActive)
                )}
        } catch {
            print(error)
        }
    }
    
    @objc func printResponse() {
        for account in AccountModel.accounts {
            print(account)
        }
    }
    
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Accessory path =", indexPath)
        
        let ownerCell = tableView.cellForRow(at: indexPath)
        print("Cell title =", ownerCell?.textLabel?.text ?? "nil")
    }*/
    
    
    
}
