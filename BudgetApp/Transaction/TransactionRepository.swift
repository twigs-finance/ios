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
}

class NetworkTransactionRepository: TransactionRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
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
}

#if DEBUG
class MockTransactionRepository: TransactionRepository {
    func getTransactions(categoryIds: [Int]? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Transaction], NetworkError> {
        return Result.Publisher([Transaction(
            id: 2,
            title: "Test Transaction",
            description: "A mock transaction used for testing",
            date: Date(),
            amount: 10000,
            categoryId: 3,
            expense: true,
            createdBy: 0,
            budgetId: 1
            )]).eraseToAnyPublisher()
    }
    
    func getTransaction(_ transactionId: Int) -> AnyPublisher<Transaction, NetworkError> {
        return Result.Publisher(Transaction(
            id: 2,
            title: "Test Transaction",
            description: "A mock transaction used for testing",
            date: Date(),
            amount: 10000,
            categoryId: 3,
            expense: true,
            createdBy: 0,
            budgetId: 1
        )).eraseToAnyPublisher()
    }
    
    func createTransaction(_ transaction: Transaction) -> AnyPublisher<Transaction, NetworkError> {
        return Result.Publisher(Transaction(
            id: 2,
            title: "Test Transaction",
            description: "A mock transaction used for testing",
            date: Date(),
            amount: 10000,
            categoryId: 3,
            expense: true,
            createdBy: 0,
            budgetId: 1
        )).eraseToAnyPublisher()
    }
}
#endif
