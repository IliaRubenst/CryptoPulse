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

class SymbolsListController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    var webSocket = WebSocketManager()
    var viewCtr: ViewController!
    var addAlarmVC: AddAlarmViewController!
    var senderState: SymbolsListSender = .mainView
    let defaults = DataLoader(keys: "savedFullSymbolsData")
    let tableView = UITableView()
    var marketManager = MarketManager()
    
    var displayedSymbols: [Symbol] {
        if isFiltering() {
            return filteredSymbols
        }
        return symbols
    }

    var symbols = SymbolsArray.symbols
    private var filteredSymbols = [Symbol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.loadUserData()
        setupUI()
        configureTableView()
        configureSearchBar()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        setupTableViewConstraints()
    }
    
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                         tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                         tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                         tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    private func configureTableView() {
        tableView.register(SymbolsListCell.self, forCellReuseIdentifier: SymbolsListCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func configureSearchBar() {
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.showsScopeBar = true

        let searchBar = searchController.searchBar
        searchBar.returnKeyType = .done
        searchBar.placeholder = "Symbol"
        searchBar.scopeButtonTitles = ["All", "USDT", "BUSD"]
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        definesPresentationContext = true
    }
    
    
    deinit {
        print("SymbolsListController деинициализрован")
    }
}

// MARK: - UITableViewDataSource Methods
extension SymbolsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSymbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymbolsListCell.identifier, for: indexPath) as? SymbolsListCell else {
            return UITableViewCell()
        }
        
        let symbol = displayedSymbols[indexPath.item]
        let symbolLabel = symbol.symbol
        let priceLabel = "Price: \(symbol.markPrice)"
        let percentLabel = "\(symbol.priceChangePercent ?? "0") %"
        let volumeFormat = symbol.volume24Format() ?? "00.00"
        let volumeLabel = "Volume 24h: \(volumeFormat)"
        
        cell.configure(symbol: symbolLabel, price: priceLabel, volume: volumeLabel, percentChange: percentLabel)
        
        ColorManager.changeSymbolsListCellColor(symbol: symbol, cell: cell)

        return cell
    }
}

// MARK: - UITableViewDelegate Methods
extension SymbolsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symbol = displayedSymbols[indexPath.item]
        
        switch senderState {
        case .mainView:
            handleMainViewSelection(with: symbol)
        case .alarmsView:
            handleAlarmsViewSelection(with: symbol)
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate Methods
extension SymbolsListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearch(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        searchController.searchBar.showsScopeBar = true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController.searchBar.showsScopeBar = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.showsScopeBar = true
        dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating Methods
extension SymbolsListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearch(searchController.searchBar.text!, scope: scope)
    }
}

extension SymbolsListController {
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return !searchBarIsEmpty || searchBarScopeIsFiltering
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
    
    private func handleMainViewSelection(with symbol: Symbol) {
        UserSymbols.savedSymbols.append(symbol)
        viewCtr.closeConnection()
        viewCtr.getSymbolToWebSocket()
        
        let defaults = DataLoader(keys: "savedSymbols")
        defaults.saveData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newSymbolAdded"), object: nil)
        
        searchController.isActive = false
    }
    
    private func handleAlarmsViewSelection(with symbol: Symbol) {
        if addAlarmVC.webSocketManager != nil {
            addAlarmVC.webSocketManager.close()
        }
        
        addAlarmVC.symbol = symbol.symbol
        addAlarmVC.closePrice = nil
        addAlarmVC.alarmPrice = nil
        addAlarmVC.updateUI()
        addAlarmVC.openWebSocket()
        
        searchController.isActive = false
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
}
