//
//  TransactionRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

#if DEBUG
class MockTransactionRepository: TransactionRepository {    
    static let transaction: Transaction = Transaction(
        id: "2",
        title: "Test Transaction",
        description: "A mock transaction used for testing",
        date: Date(),
        amount: 10000,
        categoryId: MockCategoryRepository.category.id,
        expense: true,
        createdBy: MockUserRepository.user.id,
        budgetId: MockBudgetRepository.budget.id
    )

    func getTransactions(budgetIds: [String], categoryIds: [String]?, from: Date?, to: Date?, count: Int?, page: Int?) async throws -> [Transaction] {
        return [MockTransactionRepository.transaction]
    }
    
    func getTransaction(_ transactionId: String) async throws -> Transaction {
        return MockTransactionRepository.transaction
    }
    
    func createTransaction(_ transaction: Transaction) async throws -> Transaction {
        return MockTransactionRepository.transaction
    }

    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        return MockTransactionRepository.transaction
    }
    
    func deleteTransaction(_ transactionId: String) async throws {
        // Do nothing
    }
    
    func sumTransactions(budgetId: String?, categoryId: String?, from: Date?, to: Date?) async throws -> BalanceResponse {
        return BalanceResponse(balance: 1000)
    }
}
#endif
