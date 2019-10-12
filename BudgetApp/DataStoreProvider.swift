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

    init(
        budgetRepository: BudgetRepository,
        categoryRepository: CategoryRepository,
        transactionRepository: TransactionRepository,
        userRepository: UserRepository
    ) {
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository
        self._userDataStore = UserDataStore(userRepository)
    }
}

#if DEBUG

class MockDataStoreProvider: DataStoreProvider {
    init() {
        super.init(
            budgetRepository: MockBudgetRepository(),
            categoryRepository: MockCategoryRepository(),
            transactionRepository: MockTransactionRepository(),
            userRepository: MockUserRepository()
        )
    }
}

#endif
