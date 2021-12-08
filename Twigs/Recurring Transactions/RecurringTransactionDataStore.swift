//
//  RecurringTransactionDataStore.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import Foundation
import Combine
import Collections

class RecurringTransactionDataStore: ObservableObject {
    private let repository: RecurringTransactionsRepository
    private var currentRequest: AnyCancellable? = nil
    @Published var transactions: Result<[RecurringTransaction], NetworkError>? = nil
    @Published var transaction: Result<RecurringTransaction, NetworkError>? = nil
    
    init(_ repository: RecurringTransactionsRepository, budgetId: String) {
        self.repository = repository
        getRecurringTransactions(budgetId)
    }
    
    func getRecurringTransactions(_ budgetId: String) {
        self.transactions = .failure(.loading)
        self.currentRequest = self.repository.getRecurringTransactions(budgetId: budgetId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    print("Error loading recurring transactions: \(error.name)")
                    self.transactions = .failure(error)
                }
            }, receiveValue: { (transactions) in
                self.transactions = .success(transactions.sorted(by: { $0.title < $1.title }))
            })
    }
    
    func getRecurringTransaction(_ id: String) {
        self.transaction = .failure(.loading)
        
        self.currentRequest = self.repository.getRecurringTransaction(id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.transaction = .failure(error)
                }
            }, receiveValue: { (transaction) in
                self.transaction = .success(transaction)
            })
    }
    
    func saveRecurringTransaction(_ transaction: RecurringTransaction) {
        self.transaction = .failure(.loading)
        var transactionSavePublisher: AnyPublisher<RecurringTransaction, NetworkError>
        if (transaction.id != "") {
            transactionSavePublisher = self.repository.updateRecurringTransaction(transaction)
        } else {
            transactionSavePublisher = self.repository.createRecurringTransaction(transaction)
        }
        self.currentRequest = transactionSavePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.transaction = .failure(error)
                }
            }, receiveValue: { (transaction) in
                self.transaction = .success(transaction)
                if case var .success(transactions) = self.transactions {
                    transactions.insert(transaction, at: 0)
                    self.transactions = .success(transactions)
                }
            })
    }
    
    func deleteRecurringTransaction(_ id: String) {
        self.transaction = .failure(.loading)
        
        self.currentRequest = self.repository.deleteRecurringTransaction(id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.transaction = .failure(error)
                }
            }, receiveValue: { (empty) in
                self.transaction = .failure(.deleted)
                if case let .success(transactions) = self.transactions {
                    self.transactions = .success(transactions.filter { $0.id != id })
                }
            })
    }
    
    func clearSelectedRecurringTransaction() {
        self.transaction = nil
    }
}
