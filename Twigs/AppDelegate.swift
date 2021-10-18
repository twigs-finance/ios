//
//  AppDelegate.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "First Tab", action: #selector(handleKeyCommand(sender:)), input: "1", modifierFlags: .command, propertyList: 0),
            UIKeyCommand(title: "Second Tab", action: #selector(handleKeyCommand(sender:)), input: "2", modifierFlags: .command, propertyList: 1),
            UIKeyCommand(title: "Third Tab", action: #selector(handleKeyCommand(sender:)), input: "3", modifierFlags: .command, propertyList: 2),
            UIKeyCommand(title: "Fourth Tab", action: #selector(handleKeyCommand(sender:)), input: "4", modifierFlags: .command, propertyList: 3),
            UIKeyCommand(title: "Fifth Tab", action: #selector(handleKeyCommand(sender:)), input: "5", modifierFlags: .command, propertyList: 4),
        ]
    }
    
    @objc func handleKeyCommand(sender: UIKeyCommand) {
        if let tabTag = sender.propertyList as? Int {
            NotificationCenter.default.post(name: .init("switchTabs"), object: tabTag)
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

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


}

