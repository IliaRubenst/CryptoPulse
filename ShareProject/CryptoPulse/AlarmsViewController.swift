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
        
        var defaults = DataLoader(keys: "savedAlarms")
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
        content.text = "\(item.symbol) - \(item.alarmPrice)"
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
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Accessory path =", indexPath)
        
        let ownerCell = tableView.cellForRow(at: indexPath)
        print("Cell title =", ownerCell?.textLabel?.text ?? "nil")
    }*/
    
}
