//
//  SymbolsListController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 17.09.2023.
//

import UIKit

enum SymbolsListSender {
    case mainView
    case alarmsView
}

class SymbolsListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var symbols = SymbolsArray.symbols
    private var filteredSymbols = [Symbol]()
    var webSocket = WebSocketManager()
    var viewCtr: ViewController!
    
    var addAlarmVC: AddAlarmViewController!
    var senderState: SymbolsListSender = .mainView
    
    let defaults = DataLoader(keys: "savedFullSymbolsData")
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
//        return searchController.isActive && (!searchBarIsEmpty || searchBarScopeIsFiltering)
        return !searchBarIsEmpty || searchBarScopeIsFiltering
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureTableView()
        configureSearchBar()
        
//        defaults.loadUserSymbols()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                                     tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.saveData()
    }
    
    func setupUI() {
        view.addSubview(tableView)
    }
    
    func configureTableView() {
        tableView.register(SymbolsListCell.self, forCellReuseIdentifier: SymbolsListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureSearchBar() {
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.showsScopeBar = true
        
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.placeholder = "Symbol"
        
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["All", "USDT", "BUSD"]
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredSymbols.count
        }
        return SymbolsArray.symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymbolsListCell.identifier, for: indexPath) as? SymbolsListCell else {
            fatalError("Unable to dequeue SymbolsListCell.")
        }
        var symbol: Symbol
        
        if isFiltering {
            symbol = filteredSymbols[indexPath.item]
        } else {
            symbol = SymbolsArray.symbols[indexPath.item]
        }
        
        let symbolLabel = symbol.symbol
        let priceLabel = ("Price: \(symbol.markPrice)")
        let percentLabel = ("\(symbol.priceChangePercent ?? "0") %")
        
        let volume = Double(symbol.volume ?? "0")! / 1_000_000
        let volume24h = String(format: "%.2fm$", volume)
        let volumeLabel = ("Volume 24h: \(volume24h)")
        
        cell.configure(symbolLabel: symbolLabel, priceLabel: priceLabel, volumeLabel: volumeLabel, percentChangeLabel: percentLabel)
        
        changeBorderColor(symbol, cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch senderState {
        case .mainView:
            let symbol: Symbol
            
            if isFiltering {
                symbol = filteredSymbols[indexPath.item]
            } else {
                symbol = SymbolsArray.symbols[indexPath.item]
            }
            UserSymbols.savedSymbols.append(symbol)
            viewCtr.closeConnection()
            viewCtr.getSymbolToWebSocket()
            
            let defaults = DataLoader(keys: "savedSymbols")
            defaults.saveData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newSymbolAdded"), object: nil)
            
            
        case .alarmsView:
            let symbol: Symbol
            
            if isFiltering {
                symbol = filteredSymbols[indexPath.item]
            } else {
                symbol = SymbolsArray.symbols[indexPath.item]
            }
            
            if addAlarmVC.webSocketManager != nil {
                addAlarmVC.webSocketManager.close()
            }
            
            addAlarmVC.symbol = symbol.symbol
            addAlarmVC.closePrice = nil
            addAlarmVC.updateUI()
            addAlarmVC.openWebSocket()
        }
        
        searchController.isActive = false
        dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearch(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        searchController.searchBar.showsScopeBar = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController.searchBar.showsScopeBar = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearch(searchController.searchBar.text!, scope: scope)
    }
    
    private func filterContentForSearch(_ searchText: String, scope: String = "All") {
        filteredSymbols = symbols.filter({ (symbol: Symbol) -> Bool in
            
            let categoryMatch = (scope == "All") || (symbol.symbol.lowercased().contains(scope.lowercased()))
            
            if searchBarIsEmpty {
                return categoryMatch
            }
            
            return categoryMatch && symbol.symbol.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.showsScopeBar = true
        dismiss(animated: true)
    }
    
    func changeBorderColor(_ symbol: Symbol, cell: SymbolsListCell) {
        if Double(symbol.priceChangePercent ?? "0") ?? 0 < 0 {
            cell.symbolLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            cell.percentChangeLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        } else {
            cell.symbolLabel.textColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
            cell.percentChangeLabel.textColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
        }
    }
}
