//
//  SceneDelegate.swift
//  ShareProject
//
//  Created by Ilia Ilia on 07.09.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        self.setupWindow(with: scene)
        self.checkAuthentication()
    }
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    public func checkAuthentication() {
        // Здесь будет проверка на авторизацию
        Task {
            do {
                if let currentUserUserID = SavedCurrentUser.user.id,
                   let alarmsArray = try await DataService.getAlarms(for: currentUserUserID) {
                    AlarmModelsArray.alarms = alarmsArray
                    goToController(main: true)
                } else {
                    goToController(main: false)
                }
                
            } catch ServerErrorResponse.invalidResponse(let message), ServerErrorResponse.detailError(let message), ServerErrorResponse.decodingError(let message) {
                print("DEBUG: \(message)")
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func goToController(main: Bool) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.window?.layer.opacity = 0
            } completion: { [weak self] _ in
                
                switch main {
                case true:
                    self?.window?.rootViewController = MainTabBarController()
                case false:
                    let nav = UINavigationController(rootViewController: LoginViewController())
                    nav.modalPresentationStyle = .fullScreen
                    self?.window?.rootViewController = nav
                }
                
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.window?.layer.opacity = 1
                }
            }
        }
    }
}

