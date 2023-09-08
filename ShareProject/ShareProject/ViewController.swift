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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settings))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTicker))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
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
        
        cell.tickerLabel.text = "Beta"
        cell.currentPriceLabel.text = "2.95$"
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    
    
    @objc func addTicker() {
        marketManager.fetchRequest(path: path)
    }
    
    @objc func settings() {
        
    }
    
    

        
}

