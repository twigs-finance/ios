//
//  TwigsApp.swift
//  Twigs
//
//  Created by William Brawner on 10/28/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

@main
struct TwigsApp: App {
    @StateObject var authDataStore: AuthenticationDataStore
    let apiService: TwigsApiService = TwigsInMemoryCacheService()

    init() {
        let authDataStore = AuthenticationDataStore(self.apiService)
        self._authDataStore = StateObject(wrappedValue: authDataStore)
    }
    
    @ViewBuilder
    var mainView: some View {
        if UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad {
            SidebarBudgetView(apiService)
                .environmentObject(authDataStore)
        } else {
            TabbedBudgetView(apiService)
                .environmentObject(authDataStore)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
        }
    }
}
