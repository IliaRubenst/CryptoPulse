//
//  SymbolsListController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

class SymbolsListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredSymbols = [Symbol]()
    var webSocket = WebSocketManager()
    var viewCtr: ViewController!
    let defaults = DataLoader(keys: "savedFullSymbolsData")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filteredSymbols = SymbolsArray.symbols
        
        tableView.register(SymbolsListCell.self, forCellReuseIdentifier: SymbolsListCell.identifier)
        
        searchBar.scopeButtonTitles = ["All", "USDT", "BUSD"]
        searchBar.delegate = self
        
        defaults.loadUserSymbols()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.saveData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredSymbols = SymbolsArray.symbols.filter({ $0.symbol.contains(searchText.uppercased()) })
            self.tableView.reloadData()
        } else {
            self.filteredSymbols = SymbolsArray.symbols
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSymbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymbolsListCell.identifier, for: indexPath) as? SymbolsListCell else {
            fatalError("Unable to dequeue SymbolsListCell.")
        }
        let symbolLabel = filteredSymbols[indexPath.item].symbol
        let priceLabel = ("Price: \(filteredSymbols[indexPath.item].markPrice)")
        
        let volume = Double(filteredSymbols[indexPath.item].volume ?? "0")! / 1_000_000
        let volume24h = String(format: "%.2fm$", volume)
        let volumeLabel = ("Volume 24h: \(volume24h)")
        
        cell.configure(symbolLabel: symbolLabel, priceLabel: priceLabel, volumeLabel: volumeLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredSymbols[indexPath.item]
        UserSymbols.savedSymbols.append(item)
        viewCtr.closeConnection()
        viewCtr.getSymbolToWebSocket()
        
        let defaults = DataLoader(keys: "savedSymbols")
        defaults.saveData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newSymbolAdded"), object: nil)
        dismiss(animated: true)
    }
}
