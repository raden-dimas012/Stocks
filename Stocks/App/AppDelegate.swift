//
//  AppDelegate.swift
//  Stocks
//
//  Created by Raden Dimas on 03/04/22.
//

import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {


    
    /// Gets called when app launches
    /// - Parameters:
    ///   - application: App instance
    ///   - launchOptions: Launch properties
    /// - Returns: Bool for success or failure
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        debug()
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    /// <#Description#>
    /// - Parameters:
    ///   - application: <#application description#>
    ///   - connectingSceneSession: <#connectingSceneSession description#>
    ///   - options: <#options description#>
    /// - Returns: <#description#>
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
//    private func debug() {
//        ApiCallerManager.shared.marketData(for: "AAPL", numberOfDays: 1) { result in
//            
//            switch result {
//            case .success(let data):
//                let candleStick = data.candleStick
//                debugPrint(candleStick)
//            case .failure(let error):
//                debugPrint(error)
//            }
//            
//        }
//    }


}

