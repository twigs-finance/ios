//
//  TransactionDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class TransactionDataStore: ObservableObject {
    private var currentRequest: AnyCancellable? = nil
    var transactions: Result<[Transaction], NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    var transaction: Result<Transaction, NetworkError> = .failure(.unknown) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func getTransactions(_ budget: Budget, category: Category? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) {
        self.transactions = .failure(.loading)
        
        let budgetIds: [String] = [budget.id]
        var categoryIds: [String] = []
        if category != nil {
            categoryIds.append(category!.id)
        }
        self.currentRequest = self.transactionRepository.getTransactions(
            budgetIds: budgetIds,
            categoryIds: categoryIds,
            from: Date(timeIntervalSince1970: 0),
            count: count,
            page: page
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    print("Error loading transactions: \(error.name)")
                    self.transactions = .failure(error)
                }
            }, receiveValue: { (transactions) in
                self.transactions = .success(transactions)
            })
    }
    
    func getTransaction(_ transactionId: String) {
        self.transaction = .failure(.loading)
        
        self.currentRequest = self.transactionRepository.getTransaction(transactionId)
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
    
    func saveTransaction(_ transaction: Transaction) {
        self.transaction = .failure(.loading)
        
        var transactionSavePublisher: AnyPublisher<Transaction, NetworkError>
        if (transaction.id != "") {
            transactionSavePublisher = self.transactionRepository.updateTransaction(transaction)
        } else {
            transactionSavePublisher = self.transactionRepository.createTransaction(transaction)
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
            })
    }
    
    func deleteTransaction(_ transactionId: String) {
        self.transaction = .failure(.loading)
        
        self.currentRequest = self.transactionRepository.deleteTransaction(transactionId)
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
            })
    }
    
    func reset() {
        self.transaction = .failure(.unknown)
        self.transactions = .failure(.loading)
    }
    
    let objectWillChange = ObservableObjectPublisher()
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
}
