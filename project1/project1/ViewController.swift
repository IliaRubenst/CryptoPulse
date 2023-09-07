//
//  ViewController.swift
//  project1
//
//  Created by Ilia Ilia on 17.06.2023.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    //project 12, challenge 1
    var viewsCounter = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        performSelector(inBackground: #selector(loadNssl), with: nil)
        tableView.reloadData()
        print(pictures)
        
        //project 12, challenge 1
        let defaults = UserDefaults.standard
        viewsCounter = defaults.object(forKey: "ViewsCounter") as? [String: Int] ?? [String:Int]()
    }
    
    @objc func loadNssl() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items.sorted() {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    //project 12, challenge 1
    func saveViewsCounter() {
        let defaults = UserDefaults.standard
        defaults.set(viewsCounter, forKey: "ViewsCounter")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "Amount of views: \(viewsCounter[pictures[indexPath.row], default: 0])" //project 12, challenge 1
        print("Amount of views: \(viewsCounter[pictures[indexPath.row], default: 0])")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Bad") as? DetailViewController{
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.amountOfPictures = pictures.count
            vc.tapPictures = (indexPath.row + 1)
            
            viewsCounter[pictures[indexPath.row], default: 0] += 1      //project 12, challenge 1
            saveViewsCounter()                                          //project 12, challenge 1
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

