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
    let requestHelper = RequestHelper()
    let cacheService = TwigsInMemoryCacheService()
    let apiService: TwigsApiService
    let budgetRepository: BudgetRepository
    let categoryRepository: CategoryRepository
    let transactionRepository:TransactionRepository
    let userRepository: UserRepository
    let dataStoreProvider: DataStoreProvider

    init() {
        self.apiService = TwigsApiService(requestHelper)
        self.budgetRepository = NetworkBudgetRepository(apiService, cacheService: cacheService)
        self.categoryRepository = NetworkCategoryRepository(apiService, cacheService: cacheService)
        self.transactionRepository = NetworkTransactionRepository(apiService)
        self.userRepository = NetworkUserRepository(apiService)
        self.dataStoreProvider = DataStoreProvider(
            budgetRepository: budgetRepository,
            categoryRepository: categoryRepository,
            transactionRepository: transactionRepository,
            userRepository: userRepository
        )
    }

    var body: some Scene {
        WindowGroup {
            TabbedBudgetView()
                .environmentObject(dataStoreProvider.authenticationDataStore())
                .environmentObject(dataStoreProvider.budgetsDataStore())
                .environmentObject(dataStoreProvider.categoryDataStore())
                .environmentObject(dataStoreProvider.transactionDataStore())
                .environmentObject(dataStoreProvider.userDataStore())
        }
    }
}
