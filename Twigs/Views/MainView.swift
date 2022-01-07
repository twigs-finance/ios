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
    @StateObject var transactionList: TransactionDataStore
    @StateObject var categoryList: CategoryListDataStore
    @StateObject var userDataStore: UserDataStore
    @StateObject var recurringTransactionList: RecurringTransactionDataStore
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService, baseUrl: Binding<String>, token: Binding<String>, userId: Binding<String>) {
        self.apiService = apiService
        self._authenticationDataStore = StateObject(wrappedValue: AuthenticationDataStore(apiService, baseUrl: baseUrl, token: token, userId: userId))
        self._budgetDataStore = StateObject(wrappedValue: BudgetsDataStore(budgetRepository: apiService, categoryRepository: apiService, transactionRepository: apiService))
        self._categoryList = StateObject(wrappedValue: CategoryListDataStore(apiService))
        self._userDataStore = StateObject(wrappedValue: UserDataStore(apiService))
        self._transactionList = StateObject(wrappedValue: TransactionDataStore(apiService))
        self._recurringTransactionList = StateObject(wrappedValue: RecurringTransactionDataStore(apiService))
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
            .environmentObject(transactionList)
            .environmentObject(categoryList)
            .environmentObject(budgetDataStore)
            .environmentObject(userDataStore)
            .environmentObject(recurringTransactionList)
            .environmentObject(authenticationDataStore)
            .onAppear {
                Task {
                    await self.authenticationDataStore.loadProfile()
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(TwigsInMemoryCacheService(), baseUrl: .constant(""), token: .constant(""), userId: .constant(""))
    }
}
