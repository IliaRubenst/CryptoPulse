//
//  DetailViewController.swift
//  ShareProject
//
//  Created by Ilia Ilia on 09.09.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var someText: UILabel!
    
    var symbol: String!
    var price: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            symbolLabel.text = "Current coin is \(symbol!) price \(price!) $"
        
    }
}
