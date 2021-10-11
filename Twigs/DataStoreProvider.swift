//
//  DataStoreProvider.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

/**
 Wrapper for all types of data stores. Some are considered singletons, such as the AuthenticationDataStore, while others are created as needed
 */
class DataStoreProvider {
    private let budgetRepository: BudgetRepository
    private let categoryRepository: CategoryRepository
    private let transactionRepository: TransactionRepository
    private let userRepository: UserRepository

    private let _authenticationDataStore: AuthenticationDataStore
    
    func budgetsDataStore() -> BudgetsDataStore {
        return BudgetsDataStore(budgetRepository: budgetRepository, categoryRepository: categoryRepository, transactionRepository: transactionRepository)
    }
    
    func categoryDataStore() -> CategoryDataStore {
        return CategoryDataStore(categoryRepository)
    }
    
    func transactionDataStore() -> TransactionDataStore {
        return TransactionDataStore(transactionRepository)
    }
    
    func authenticationDataStore() -> AuthenticationDataStore {
        return self._authenticationDataStore
    }
    
    func userDataStore() -> UserDataStore {
        return UserDataStore(userRepository)
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
        self.userRepository = userRepository
        self._authenticationDataStore = AuthenticationDataStore(userRepository)
    }
}

#if DEBUG

class MockDataStoreProvider: DataStoreProvider {
    
    override func authenticationDataStore() -> AuthenticationDataStore {
        return MockAuthenticationDataStore(MockUserRepository())
    }
    
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
