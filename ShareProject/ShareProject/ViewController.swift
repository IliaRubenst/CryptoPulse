//
//  ViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 07.09.2023.
//

import UIKit

class ViewController: UICollectionViewController {
    let amountCells = 2
    let offSet: CGFloat = 4.0
    var path = "/fapi/v1/premiumIndex"
    var coins = [Coin]()
    var marketManager = MarketManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTicker()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settings))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTicker))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SymbolsArray.symbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameVC = collectionView.frame
        
        let widthCell = frameVC.width / CGFloat(amountCells)
        let heightCell = widthCell
        
        let spacing = CGFloat((amountCells + 4)) * offSet / CGFloat(amountCells)
        return CGSize(width: widthCell - spacing, height: heightCell - (offSet * 3))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Coin", for: indexPath) as? CoinCell else {
            fatalError("Unable to dequeue CoinCell.")
        }
        
        cell.tickerLabel.text = SymbolsArray.symbols[indexPath.item].symbol
        cell.currentPriceLabel.text = SymbolsArray.symbols[indexPath.item].markPrice
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CoinCell else { return }
        openDetailView(indexPath: indexPath)
    }
    
    func openDetailView(indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailData") as? DetailViewController {
            detailVC.symbol = SymbolsArray.symbols[indexPath.item].symbol
            detailVC.price = SymbolsArray.symbols[indexPath.item].markPrice

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    @objc func addTicker() {
        marketManager.fetchRequest(path: path, action: { [weak self] in
            self?.collectionView.reloadData()
            print("Вызвали action!")
        })
    }
    
    @objc func settings() {
        
    }
}

