//
//  RecurringTransactionsRepository.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

#if DEBUG
class MockRecurringTransactionRepository: RecurringTransactionsRepository {
    static let transaction: RecurringTransaction = RecurringTransaction(
        id: "2",
        title: "Test Transaction",
        description: "A mock transaction used for testing",
        frequency: Frequency(unit: .daily, count: 1, time: Time(from: "09:00:00")!)!,
        start: Date(),
        finish: nil,
        amount: 10000,
        categoryId: MockCategoryRepository.category.id,
        expense: true,
        createdBy: MockUserRepository.currentUser.id,
        budgetId: MockBudgetRepository.budget.id
    )

    func getRecurringTransactions(_ budgetId: String) async throws -> [RecurringTransaction] {
        return [MockRecurringTransactionRepository.transaction]
    }
    
    func getRecurringTransaction(_ id: String) async throws -> RecurringTransaction {
        return MockRecurringTransactionRepository.transaction
    }
    
    func createRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return MockRecurringTransactionRepository.transaction
    }

    func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction {
        return MockRecurringTransactionRepository.transaction
    }
    
    func deleteRecurringTransaction(_ id: String) async throws {
    }
}
#endif
