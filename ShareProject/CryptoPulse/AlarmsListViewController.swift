//
//  AlarmsViewController.swift
//  CyptoPulse
//
//  Created by Vitaly on 21.09.2023.
//

import UIKit

class AlarmsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var filtredAlarms: [AlarmModel] = []
    var accounts = [Account]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = DataLoader(keys: "savedAlarms")
        defaults.loadUserSymbols()
        
        configureNavButtons()
        configureSearchBar()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filtredAlarms = AlarmModelsArray.alarms
        tableView.reloadData()
    }
    
    func configureNavButtons() {
        let eraseList = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeAlarmsFromList))
        let addAlarm = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        
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
//        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: AlarmTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95),
            tableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
            /*tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)*/])
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
        
        present(vc, animated: true)
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
        return filtredAlarms.count
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier, for: indexPath) as? AlarmTableViewCell else { fatalError("Fatal error in AlarmVC CellForRow Method") }
        
        let item = filtredAlarms[indexPath.item]
        
        cell.tickerLabel.text = " \(item.symbol)"
        cell.dateLabel.text = " Date"
        cell.priceLabel.text = "\(item.alarmPrice)"
        cell.statusLabel.text = "\(item.isActive)"
        
        /*var content = UIListContentConfiguration.cell()
        
        
        content.text = "\(item.symbol) - \(item.alarmPrice). isActive: \(item.isActive)"
        cell.contentConfiguration = content
        
        cell.accessoryType = .detailButton
        
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
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailData") as? DetailViewController {
            detailVC.symbol = filtredAlarms[indexPath.item].symbol
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if AlarmModelsArray.alarms.count != 0 {
                let id = AlarmModelsArray.alarms[indexPath.item].id
                removeDBData(remove: id)
                print("Make delete request id:\(id)")
            }
            AlarmModelsArray.alarms.remove(at: indexPath.item)
            filtredAlarms.remove(at: indexPath.item)

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
