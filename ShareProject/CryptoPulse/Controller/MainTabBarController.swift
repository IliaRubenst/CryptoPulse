//
//  MainTabBarController.swift
//  CyptoPulse
//
//  Created by Vitaly on 19.10.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBars()
        
        print(SavedCurrentUser.user.description)
    }
    
    private func generateTabBars() {
        viewControllers = [
            generateVC(viewController: MainViewController(),
                       title: "Мои списки",
                       image: UIImage(systemName: "folder.fill"),
                       navController: true),
            generateVC(viewController: AlarmsListViewController(),
                       title: "Уведомления",
                       image: UIImage(systemName: "alarm.fill"),
                       navController: true),
            generateVC(viewController: SettingsViewController(),
                       title: "Настройки",
                       image: UIImage(systemName: "gearshape.fill"),
                       navController: false)
        ]
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?, navController: Bool) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        
        if navController {
            return UINavigationController(rootViewController: viewController)
        } else {
            return viewController
        }
    }
    
}
