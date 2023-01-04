//
//  TwigsApp.swift
//  Twigs
//
//  Created by William Brawner on 10/28/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import FirebaseCore
import SwiftUI
import TwigsCore

@main
struct TwigsApp: App {
    @StateObject var apiService: TwigsInMemoryCacheService = TwigsInMemoryCacheService()

    var body: some Scene {
        WindowGroup {
            MainView(apiService as TwigsApiService)
        }
    }
    
    init() {
        FirebaseApp.configure()
    }
}
