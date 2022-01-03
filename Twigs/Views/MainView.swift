//
//  MainView.swift
//  Twigs
//
//  Created by William Brawner on 12/30/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct MainView: View {
    @StateObject var authenticationDataStore: AuthenticationDataStore
    @StateObject var budgetDataStore: BudgetsDataStore
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService, baseUrl: Binding<String>, token: Binding<String>, userId: Binding<String>) {
        self.apiService = apiService
        self._authenticationDataStore = StateObject(wrappedValue: AuthenticationDataStore(apiService, baseUrl: baseUrl, token: token, userId: userId))
        self._budgetDataStore = StateObject(wrappedValue: BudgetsDataStore(budgetRepository: apiService, categoryRepository: apiService, transactionRepository: apiService))
    }
    
    @ViewBuilder
    var mainView: some View {
        if UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad {
            SidebarBudgetView(apiService: apiService)
                .environmentObject(authenticationDataStore)
                .environmentObject(budgetDataStore)
        } else {
            TabbedBudgetView(apiService: apiService)
                .environmentObject(authenticationDataStore)
                .environmentObject(budgetDataStore)
        }
    }
    
    var body: some View {
        mainView.onAppear {
            print("MainView.onAppear")
            Task {
                try await self.authenticationDataStore.loadProfile()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(TwigsInMemoryCacheService(), baseUrl: .constant(""), token: .constant(""), userId: .constant(""))
    }
}
