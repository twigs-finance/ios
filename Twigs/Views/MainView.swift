//
//  MainView.swift
//  Twigs
//
//  Created by William Brawner on 12/30/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import FirebaseCore
import SwiftUI
import TwigsCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

struct MainView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var dataStore: DataStore
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService) {
        self.apiService = apiService
        self._dataStore = StateObject(wrappedValue: DataStore(apiService, errorReporter: FirebaseErrorReporter()))
    }
    
    @ViewBuilder
    var mainView: some View {
        if UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad {
            SidebarBudgetView()
        } else {
            TabbedBudgetView()
        }
    }
    
    var body: some View {
        mainView
            .environmentObject(dataStore)
            .onAppear {
                Task {
                    await self.dataStore.loadProfile()
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(TwigsInMemoryCacheService())
    }
}
