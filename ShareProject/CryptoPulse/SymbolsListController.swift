//
//  SymbolsListController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

class SymbolsListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WebSocketManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredSymbols = [Symbol]()
    
    var webSocket = WebSocketManager()
    var viewCtr: ViewController!
    let defaults = DataLoader(keys: "savedFullSymbolsData")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.filteredSymbols = SymbolsArray.symbols
        self.filteredSymbols = SymbolsArray.symbols
        
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredSymbols[indexPath.item].symbol
        
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
    
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol]) {
        
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        
    }
    
    func didUpdateMarkPriceStream(_ websocketManager: WebSocketManager, dataModel: MarkPriceStreamModel) {
        
    }
    
    func didUpdateIndividualSymbolTicker(_ websocketManager: WebSocketManager, dataModel: IndividualSymbolTickerStreamsModel) {
        
    }
    

}
