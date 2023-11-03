//
//  ViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 07.09.2023.
//


import UIKit

class ViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let amountCells = 2
    private let marketManager = MarketManager()
    private let dbManager = DataBaseManager()
    private let webSocket = WebSocketManager()
    
//    private var webSocketManagers = [WebSocketManager]()
    
    private var socketManagers: [String: WebSocketManager] = [:]

    private var isSelected = false
    private var isReload = false
    private var currentVolume = "0.0"
    private let timeFrame = "1m"
//    private let customIndexPath = IndexPath(row: index, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        loadTickers()
        loadUserData()
        getSymbolToWebSocket()
        performRequestDB()
        navigationItem.title = ""
        setupRightButtonItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "newSymbolAdded"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTickers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveFullSymbolsData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7),
                                     collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7),
                                     collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    private func configureCollectionView() {
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupRightButtonItems() {
        let showTableViewButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle.portrait")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(showTableView))
        
        navigationItem.rightBarButtonItems = [showTableViewButton]
    }
    
    deinit {
        print("ViewController деинициализрован")
    }
}

// MARK: - UICollectionViewDataSource Methods
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserSymbols.savedSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let symbol = UserSymbols.savedSymbols[indexPath.item]
        cell.configure(with: symbol)
        
        ColorManager.changeCoinCell(indexPath: indexPath, cell: cell)
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate Methods
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openDetailView(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        isSelected = true
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let removeAction = self?.createContextAction(title: "Remove", iconName: "trash") {
                self?.contextMenuAction(indexPath, action: "remove")
            }
            let changeColorAction = self?.createContextAction(title: "Change color", iconName: "paintbrush") {
                self?.contextMenuAction(indexPath, action: "change")
            }
            return UIMenu(title: "Action", children: [removeAction, changeColorAction].compactMap { $0 })
        }
        return config
    }
    
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        isSelected = false
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameVC = collectionView.frame
        let offSet: CGFloat = 3.0
        
        let widthCell = frameVC.width / CGFloat(amountCells)
        let heightCell = widthCell / 2
        
        let spacing = CGFloat((amountCells + 2)) * offSet / CGFloat(amountCells)
        return CGSize(width: widthCell - spacing, height: heightCell - (offSet * 3))
    }
}

// MARK: - WebSocketManagerDelegate Methods
extension ViewController: WebSocketManagerDelegate {
    func getSymbolToWebSocket() {
        for symbol in UserSymbols.savedSymbols {
            setConnectForSymbols(symbol.symbol)
        }
        let delegate = WebSocketManager()
        delegate.delegate = self
        delegate.actualState = State.tickerarr
        delegate.webSocketConnect(symbol: "btcusdt", timeFrame: timeFrame)
//        webSocketManagers.append(delegate)
        socketManagers["btcusdt"] = delegate
    }

    func setConnectForSymbols(_ symbol: String) {
        if let manager = socketManagers[symbol] {
            return
        }
        
        let delegate = WebSocketManager()
        delegate.delegate = self
        delegate.actualState = State.currentCandleData
        delegate.webSocketConnect(symbol: symbol, timeFrame: timeFrame)
        socketManagers[symbol] = delegate
    }
    
    func didUpdateCandle(_ websocketManager: WebSocketManager, candleModel: CurrentCandleModel) {
        let gotSymbol = candleModel.pair
        let currentPrice = candleModel.closePrice
        if let index = UserSymbols.savedSymbols.firstIndex(where: { $0.symbol == gotSymbol }) {
            UserSymbols.savedSymbols[index].markPrice = currentPrice
            
            if !isSelected {
                reloadCellData(index)
            }
        }
    }
    
    func didUpdateminiTicker(_ websocketManager: WebSocketManager, dataModel: [Symbol]) {
        for symbol in dataModel {
                if let index = UserSymbols.savedSymbols.firstIndex(where: { $0.symbol == symbol.symbol }) {
                    UserSymbols.savedSymbols[index].volume = symbol.volume24Format()
                    UserSymbols.savedSymbols[index].priceChangePercent = symbol.priceChangePercent
                    
                    if !isSelected {
//                        let indexPath = IndexPath(item: index, section: 0)
//                        collectionView.reloadItems(at: [indexPath])
                        reloadCellData(index)
                    }
                }
            }
    }

    func closeConnection() {
        for delegate in socketManagers {
            delegate.value.close()
        }
    }
}

extension ViewController {
    private func loadUserData() {
        let defaults = DataLoader(keys: "savedSymbols")
        defaults.loadUserData()
    }
    
    private func saveFullSymbolsData() {
        let defaults = DataLoader(keys: "savedFullSymbolsData")
        defaults.saveData()
    }
    
    private func performRequestDB() {
        dbManager.performRequestDB() { data, error in
            if let error = error {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Ошибка",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(action)
                    self.present(alertController, animated: true)
                }
                
                return
            }
        }
    }
    
    private func createContextAction(title: String, iconName: String, action: @escaping () -> Void) -> UIAction {
        return UIAction(title: title, image: UIImage(systemName: iconName)) { [weak self] _ in
            action()
            if title == "Remove" {
                let defaults = DataLoader(keys: "savedSymbols")
                defaults.saveData()
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func contextMenuAction(_ indexPath: IndexPath, action: String) {
        guard let currentCell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        if action == "change" {
            currentCell.changeColor()
        } else if action == "remove" {
            currentCell.removeCell(at: indexPath.item)
        }
    }
    
    private func reloadCellData(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
            cell.configure(with: UserSymbols.savedSymbols[index])
        }
    }
    
    func openDetailView(indexPath: IndexPath) {
        let chartVC = DetailViewController()
        chartVC.symbol = UserSymbols.savedSymbols[indexPath.item].symbol
        chartVC.price = UserSymbols.savedSymbols[indexPath.item].markPrice
        
        navigationController?.pushViewController(chartVC, animated: true)
    }
    
    @objc private func loadList(notification: NSNotification) {
        self.collectionView.reloadData()
    }
    
    @objc func showTableView() {
        let detailVC = SymbolsListController()
        detailVC.viewCtr = self

        present(detailVC, animated: true)
    }
    
    @objc func loadTickers() {
        marketManager.fetchRequest() { [weak self] result in
            switch result {
            case .success(let newSymbols):
                DispatchQueue.main.async {
                    SymbolsArray.symbols = newSymbols
                    self?.saveFullSymbolsData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

