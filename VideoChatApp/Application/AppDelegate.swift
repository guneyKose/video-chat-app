//
//  AppDelegate.swift
//  VideoChatApp
//
//  Created by Güney Köse on 7.06.2023.
//


import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let navigation = UINavigationController()
        let landingVC = LandingViewController(viewModel: LandingViewModel())
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = navigation
        navigation.navigationBar.tintColor = .label
        navigation.viewControllers = [landingVC]
        return true
    }
}
