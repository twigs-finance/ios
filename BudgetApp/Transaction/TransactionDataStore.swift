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
    
    func getTransactions(_ category: Category? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) {
        self.transactions = .failure(.loading)
        
        var categoryIds: [Int] = []
        if category != nil {
            categoryIds.append(category!.id!)
        }
        _ = self.transactionRepository.getTransactions(
            categoryIds: categoryIds,
            from: Date(timeIntervalSince1970: 0),
            count: count,
            page: page
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self.transactions = .failure(error)
                }
            }, receiveValue: { (transactions) in
                self.transactions = .success(transactions)
            })
    }
    
    func getTransaction(_ transactionId: Int) {
        self.transaction = .failure(.loading)
        
        _ = self.transactionRepository.getTransaction(transactionId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
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
        if (transaction.id != nil) {
            transactionSavePublisher = self.transactionRepository.updateTransaction(transaction)
        } else {
            transactionSavePublisher = self.transactionRepository.createTransaction(transaction)
        }
        _ = transactionSavePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self.transaction = .failure(error)
                }
            }, receiveValue: { (transaction) in
                self.transaction = .success(transaction)
            })
    }
    
    let objectWillChange = ObservableObjectPublisher()
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
}
