//
//  AppCoordinator.swift
//  Movie
//
//  Created by Viet Phan on 22/03/2022.
//

import UIKit

class AppCoordinator {
    
    var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showHome() {
        guard let window = window else { return }
        let homeVC = HomeViewController()
        homeVC.bind(to: HomeViewModel(), to: HomeCoodinator(window: window))
        let roootNavigation = UINavigationController(rootViewController: homeVC)
        window.makeKeyAndVisible()
        window.rootViewController = roootNavigation
    }
}
