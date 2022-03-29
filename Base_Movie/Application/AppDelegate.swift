//
//  AppDelegate.swift
//  Base_Movie
//
//  Created by Viet Phan on 23/03/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var appCoodinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        appCoodinator = AppCoordinator(window: window)
        appCoodinator.showHome()
        return true
    }
}
