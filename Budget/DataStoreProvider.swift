//
//  DataStoreProvider.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

/**
 Wrapper for all types of data stores. Some are considered singletons, such as the UserDataStore, while others are created as needed
 */
class DataStoreProvider {
    private let budgetRepository: BudgetRepository
    private let categoryRepository: CategoryRepository
    private let transactionRepository: TransactionRepository
    private let userRepository: UserRepository
    
    private let _userDataStore: UserDataStore
    
    func budgetsDataStore() -> BudgetsDataStore {
        return BudgetsDataStore(budgetRepository)
    }
    
    func categoryDataStore() -> CategoryDataStore {
        return CategoryDataStore(categoryRepository)
    }
    
    func transactionDataStore() -> TransactionDataStore {
        return TransactionDataStore(transactionRepository)
    }
    
    func userDataStore() -> UserDataStore {
        return self._userDataStore
    }

    init(_ baseUrl: String) {
        let requestHelper = RequestHelper(baseUrl)
        let apiService = BudgetApiService(requestHelper)
        budgetRepository = BudgetRepository(apiService)
        categoryRepository = CategoryRepository(apiService)
        transactionRepository = TransactionRepository(apiService)
        userRepository = UserRepository(apiService)

        _userDataStore = UserDataStore(userRepository)
    }
}
