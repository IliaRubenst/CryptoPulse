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
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eraseListButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeAlarmsFromList))
        navigationItem.rightBarButtonItem = eraseListButton
        
        //кнопки потом удалим, нужны для тестов
        let printBtn = UIBarButtonItem(image: UIImage(systemName: "printer")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(printResponse))
        navigationItem.leftBarButtonItems = [printBtn]
        
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
            if AlarmModelsArray.alarms.count != 0 {
                let id = AlarmModelsArray.alarms[indexPath.item].id
                removeDBData(remove: id)
                print("Make delete request id:\(id)")
            }
            AlarmModelsArray.alarms.remove(at: indexPath.item)

            let defaults = DataLoader(keys: "savedAlarms")
            defaults.saveData()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    @objc func printResponse() {
        for account in AlarmModelsArray.alarms {
            print(account)
        }
    }
    
    // метод пока не готов
//    func updateDBData() {
//        // указать конкретный объект
//        if let url = URL(string: "http://127.0.0.1:8000/api/account/1/") {
//
//            let accountData = accounts[0]
//            guard let encoded = try? JSONEncoder().encode(accountData) else {
//                print("Failed to encode alarm")
//                return
//            }
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "PUT"
//            request.addValue("application/JSON", forHTTPHeaderField: "Accept")
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
//            request.httpBody = encoded
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                  if let data = data {
//                      if let response = try? JSONDecoder().decode(Account.self, from: data) {
//                          return
//                      }
//
//                  }
//              }.resume()
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//            }
//            task.resume()
//        }
//    }
    
    
    func removeDBData(remove id: Int) {
        if let url = URL(string: "http://127.0.0.1:8000/api/account/\(id)/") {
            var request = URLRequest(url: url)
            print(url)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
            }
            task.resume()
        }
    }
    
//    func addAlarmtoModelDB() {
//        if let url = URL(string: "http://127.0.0.1:8000/api/account/") {
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue("Basic aWxpYTpMSmtiOTkyMDA4MjIh", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                
//                if let data = data {
//                    if let response = try? JSONDecoder().decode(AlarmModel.self, from: data) {
//                        return
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
    
    
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Accessory path =", indexPath)
        
        let ownerCell = tableView.cellForRow(at: indexPath)
        print("Cell title =", ownerCell?.textLabel?.text ?? "nil")
    }*/
    
    
    
}
