//
//  SceneDelegate.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    #if DEBUG
    // Uncomment this for local development
//            static let baseUrl = "http://localhost:8080"
    static let baseUrl = "https://twigs.wbrawner.com"
    #else
    static let baseUrl = "https://twigs.wbrawner.com"
    #endif
    var window: UIWindow?
    let dataStoreProvider: DataStoreProvider

    override init() {
        // TODO: Dependency injection?
        let requestHelper = RequestHelper(SceneDelegate.baseUrl)
        let cacheService = BudgetAppInMemoryCacheService()
        let apiService = BudgetAppApiService(requestHelper)
        let budgetRepository = NetworkBudgetRepository(apiService, cacheService: cacheService)
        let categoryRepository = NetworkCategoryRepository(apiService, cacheService: cacheService)
        let transactionRepository = NetworkTransactionRepository(apiService)
        let userRepository = NetworkUserRepository(apiService)
        dataStoreProvider = DataStoreProvider(
            budgetRepository: budgetRepository,
            categoryRepository: categoryRepository,
            transactionRepository: transactionRepository,
            userRepository: userRepository
        )
        super.init()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(dataStoreProvider)
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

