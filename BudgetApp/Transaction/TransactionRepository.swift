//
//  TransactionRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

protocol TransactionRepository {
    func getTransactions(categoryIds: [Int]?, from: Date?, count: Int?, page: Int?) -> AnyPublisher<[Transaction], NetworkError>
    func getTransaction(_ transactionId: Int) -> AnyPublisher<Transaction, NetworkError>
    func createTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError>
    func updateTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError>
    func deleteTransaction(_ transactionId: Int) -> AnyPublisher<Empty, NetworkError>
}

class NetworkTransactionRepository: TransactionRepository {
    let apiService: BudgetAppApiService
    
    init(_ apiService: BudgetAppApiService) {
        self.apiService = apiService
    }
    
    func getTransactions(categoryIds: [Int]?, from: Date?, count: Int?, page: Int?) -> AnyPublisher<[Transaction], NetworkError> {
        return apiService.getTransactions(categoryIds: categoryIds, from: from, count: count, page: page)
    }
    
    func getTransaction(_ transactionId: Int) -> AnyPublisher<Transaction, NetworkError> {
        return apiService.getTransaction(transactionId)
    }
    
    func createTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return apiService.newTransaction(transaction)
    }

    func updateTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return apiService.updateTransaction(transaction)
    }
    
    func deleteTransaction(_ transactionId: Int) -> AnyPublisher<Empty, NetworkError> {
        return apiService.deleteTransaction(transactionId)
    }
}

#if DEBUG
class MockTransactionRepository: TransactionRepository {
    static let transaction: Transaction = Transaction(
        id: 2,
        title: "Test Transaction",
        description: "A mock transaction used for testing",
        date: Date(),
        amount: 10000,
        categoryId: MockCategoryRepository.category.id!,
        expense: true,
        createdBy: MockUserRepository.user.id!,
        budgetId: MockBudgetRepository.budget.id!
    )

    func getTransactions(categoryIds: [Int]?, from: Date?, count: Int?, page: Int?) -> AnyPublisher<[Transaction], NetworkError> {
        return Result.Publisher([MockTransactionRepository.transaction]).eraseToAnyPublisher()
    }
    
    func getTransaction(_ transactionId: Int) -> AnyPublisher<Transaction, NetworkError> {
        return Result.Publisher(MockTransactionRepository.transaction).eraseToAnyPublisher()
    }
    
    func createTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return Result.Publisher(MockTransactionRepository.transaction).eraseToAnyPublisher()
    }

    func updateTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return Result.Publisher(MockTransactionRepository.transaction).eraseToAnyPublisher()
    }
    
    func deleteTransaction(_ transactionId: Int) -> AnyPublisher<Empty, NetworkError> {
        return Result.Publisher(.success(Empty())).eraseToAnyPublisher()
    }
}
#endif
