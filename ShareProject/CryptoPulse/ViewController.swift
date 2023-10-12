//
//  ViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 07.09.2023.
//

// Коммит для Илюши.

import UIKit

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, WebSocketManagerDelegate {
    let amountCells = 2
    var marketManager = MarketManager()
    var dbManager = DataBaseManager()
    
    var webSocket = WebSocketManager()
    var isSelected = false
    var isReload = false
    var currentVolume = "0.0"
    
    var data: FullSymbolsArray!
    
    var webSocketManagers = [WebSocketManager]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTickers()
        
        let defaults = DataLoader(keys: "savedSymbols")
        defaults.loadUserSymbols()
        
        getSymbolToWebSocket()
        dbManager.performRequestDB()

        self.navigationItem.title = ""
        
        let showTableViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle.portrait")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(showTableView))
        navigationItem.rightBarButtonItems = [showTableViewButton]
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "newSymbolAdded"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = DataLoader(keys: "savedFullSymbolsData")
        defaults.saveData()
    }
    
    @objc func loadList(notification: NSNotification) {
        self.collectionView.reloadData()
    }
    
    @objc func showTableView() {
        let detailVC = storyboard?.instantiateViewController(identifier: "SymbolList") as! SymbolsListController
        detailVC.viewCtr = self

        present(detailVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserSymbols.savedSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameVC = collectionView.frame
        let offSet: CGFloat = 4.0
        
        let widthCell = frameVC.width / CGFloat(amountCells)
        let heightCell = widthCell / 2
        
        let spacing = CGFloat((amountCells + 2)) * offSet / CGFloat(amountCells)
        return CGSize(width: widthCell - spacing, height: heightCell - (offSet * 3))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Coin", for: indexPath) as? CoinCell else {
            fatalError("Unable to dequeue CoinCell.")
        }
        cell.tickerLabel.text = UserSymbols.savedSymbols[indexPath.item].symbol
        cell.currentPriceLabel.text = UserSymbols.savedSymbols[indexPath.item].markPrice
        cell.volumeLabel.text = UserSymbols.savedSymbols[indexPath.item].volume
        cell.percentChangeLabel.text = ("\(UserSymbols.savedSymbols[indexPath.item].priceChangePercent ?? "0") %")
        
        changeBorderColor(indexPath, cell: cell)
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? CoinCell else { return }

        openDetailView(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPaths: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        isSelected = true
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [self] _ in
            
            let remove = UIAction(title: "Remove",
                                  image: UIImage(systemName: "trash"),
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  state: .off
            ) { [weak self] _ in
                let action = "remove"
                self?.contextMenuAction(indexPaths, action: action)
                
                let defaults = DataLoader(keys: "savedSymbols")
                defaults.saveData()
                
                collectionView.reloadData()
            }
            
            let changeColor = UIAction(title: "Change color",
                                       image: UIImage(systemName: "paintbrush"),
                                       identifier: nil,
                                       discoverabilityTitle: nil,
                                       state: .off
            ) { [weak self] _ in
                let action = "change"
                self?.contextMenuAction(indexPaths, action: action)
            }
            
            return UIMenu(title: "Action",
                          image: nil,
                          identifier: nil,
                          options: UIMenu.Options.displayInline,
                          children: [remove, changeColor])
        }
        return config
    }
    
    func contextMenuAction(_ indexPath: IndexPath, action: String) {
        guard let currentCell = collectionView.cellForItem(at: indexPath) as? CoinCell else { return }
        if action == "change" {
            currentCell.changeColor()
        } else if action == "remove" {
            currentCell.removeCell(indexPath.item)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        isSelected = false
    }
    
    func openDetailView(indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailData") as? DetailViewController {
            detailVC.symbol = UserSymbols.savedSymbols[indexPath.item].symbol
            detailVC.price = UserSymbols.savedSymbols[indexPath.item].markPrice

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    @objc func loadTickers() {
        marketManager.fetchRequest()
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        let gotSymbol = candleModel.pair
        let currentPrice = candleModel.closePrice
//        var checkedArray = UserSymbols.savedSymbols.map ({ checkedArray in
        _ = UserSymbols.savedSymbols.map ({ checkedArray in
            if checkedArray.symbol == gotSymbol {
                let index = UserSymbols.savedSymbols.firstIndex { $0.symbol == gotSymbol }
                checkedArray.markPrice = currentPrice
                if !isSelected {
                    reloadCurrentCellData(index!)
                }
            }
            return checkedArray
        })
    }
    
    func reloadCurrentCellData(_ index: Int) {
        if !isReload {
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            isReload = true
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, qos: .default) { [self] in
                isReload = false
            }
        }
    }
    
    func getSymbolToWebSocket() {
        for symbol in UserSymbols.savedSymbols {
            setConnetcForSymbols(symbol.symbol)
        }
        let delegate = WebSocketManager()
        delegate.delegate = self
        delegate.actualState = State.tickerarr
        delegate.webSocketConnect(symbol: "btcusdt", timeFrame: "1m")
        webSocketManagers.append(delegate)
    }

    func setConnetcForSymbols(_ symbol: String) {
        let delegate = WebSocketManager()
        delegate.delegate = self
        delegate.actualState = State.currentCandleData
        delegate.webSocketConnect(symbol: symbol, timeFrame: "1m")
        webSocketManagers.append(delegate)
    }
    
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol]) {
        for symbol in SymbolsArray.symbols {
            if let index = UserSymbols.savedSymbols.firstIndex(where: { $0.symbol == symbol.symbol }) {

                UserSymbols.savedSymbols[index].volume = symbol.volume24Format()
                UserSymbols.savedSymbols[index].priceChangePercent = symbol.priceChangePercent
            }
        }
        if !isSelected {
            collectionView.reloadData()
        }
    }

    func closeConnection() {
        for delegate in webSocketManagers {
            delegate.close()
        }
    }
    
    func changeBorderColor(_ indexPath: IndexPath, cell: CoinCell) {
        if Double(UserSymbols.savedSymbols[indexPath.item].priceChangePercent ?? "0") ?? 0 < 0 {
            cell.percentChangeLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        } else {
            cell.percentChangeLabel.textColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
            cell.layer.borderColor = #colorLiteral(red: 0.008301745169, green: 0.5873891115, blue: 0.5336645246, alpha: 1)
        }
    }
}

