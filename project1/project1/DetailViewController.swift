//
//  DetailViewController.swift
//  project1
//
//  Created by Ilia Ilia on 18.06.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var amountOfPictures: Int?
    var tapPictures: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedImage != nil, "Picture not found")

        title = ("Picture \(tapPictures!) of \(amountOfPictures!)")
        
        navigationItem.largeTitleDisplayMode = .never
        
        // Make the navigation bar's title with some text.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGroupedBackground //Set color of navBbar
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Set color of the name.
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
