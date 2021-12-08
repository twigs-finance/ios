//
//  RecurringTransactionsRepository.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import Combine

protocol RecurringTransactionsRepository {
    func getRecurringTransactions(budgetId: String) -> AnyPublisher<[RecurringTransaction], NetworkError>
    func getRecurringTransaction(_ id: String) -> AnyPublisher<RecurringTransaction, NetworkError>
    func createRecurringTransaction(_ transaction: RecurringTransaction) -> AnyPublisher<RecurringTransaction, NetworkError>
    func updateRecurringTransaction(_ transaction: RecurringTransaction) -> AnyPublisher<RecurringTransaction, NetworkError>
    func deleteRecurringTransaction(_ id: String) -> AnyPublisher<Empty, NetworkError>
}

#if DEBUG
class MockRecurringTransactionRepository: RecurringTransactionsRepository {
    static let transaction: RecurringTransaction = RecurringTransaction(
        id: "2",
        title: "Test Transaction",
        description: "A mock transaction used for testing",
        frequency: Frequency(unit: .daily, count: 1, time: Time(from: "09:00:00")!)!,
        start: Date(),
        end: nil,
        amount: 10000,
        categoryId: MockCategoryRepository.category.id,
        expense: true,
        createdBy: MockUserRepository.user.id,
        budgetId: MockBudgetRepository.budget.id
    )

    func getRecurringTransactions(budgetId: String) -> AnyPublisher<[RecurringTransaction], NetworkError> {
        return Result.Publisher([MockRecurringTransactionRepository.transaction]).eraseToAnyPublisher()
    }
    
    func getRecurringTransaction(_ id: String) -> AnyPublisher<RecurringTransaction, NetworkError> {
        return Result.Publisher(MockRecurringTransactionRepository.transaction).eraseToAnyPublisher()
    }
    
    func createRecurringTransaction(_ transaction: RecurringTransaction) -> AnyPublisher<RecurringTransaction, NetworkError> {
        return Result.Publisher(MockRecurringTransactionRepository.transaction).eraseToAnyPublisher()
    }

    func updateRecurringTransaction(_ transaction: RecurringTransaction) -> AnyPublisher<RecurringTransaction, NetworkError> {
        return Result.Publisher(MockRecurringTransactionRepository.transaction).eraseToAnyPublisher()
    }
    
    func deleteRecurringTransaction(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return Result.Publisher(.success(Empty())).eraseToAnyPublisher()
    }
}
#endif
