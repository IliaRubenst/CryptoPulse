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
    var coins = [Coin]()
    
    
    let binanceURL = "https://fapi.binance.com"     // перенести в Coin
    var path = "/fapi/v1/exchangeInfo"                      // перенести в Coin
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        fetchRequest(path: path)
    }
    
    @objc func settings() {
        
    }
    
    
    // эту часть кода мы перенесем в Coin class
    func fetchRequest(path: String) {
        let urlString = binanceURL + path
        performRequest(urlString: urlString)
        print(urlString)
    }

    func performRequest(urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            
            let task = session.dataTask(with: url) { [self] (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    parseJSON(marketData: safeData)
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(marketData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Coin.self, from: marketData)
            
            print(decodedData.assets[1].asset)
        } catch {
            print(error)
        }
    }
        
}

