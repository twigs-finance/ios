//
//  TransactionDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import Collections

class TransactionDataStore: ObservableObject {
    private var currentRequest: AnyCancellable? = nil
    private var sumRequests: [String:AnyCancellable] = [:]
    @Published var transactions: [String:Result<OrderedDictionary<String, [Transaction]>, NetworkError>] = ["": .failure(.loading)]
    @Published var transaction: Result<Transaction, NetworkError> = .failure(.unknown)
    @Published var sums: [String:Result<BalanceResponse, NetworkError>] = ["": .failure(.loading)]

    func getTransactions(_ budgetId: String, categoryId: String? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) -> String {
        let requestId = "\(budgetId)-\(categoryId ?? "all")"
        self.transactions[requestId] = .failure(.loading)
        
        var categoryIds: [String] = []
        if let categoryId = categoryId {
            categoryIds.append(categoryId)
        }
        self.currentRequest = self.transactionRepository.getTransactions(
            budgetIds: [budgetId],
            categoryIds: categoryIds,
            from: from ?? Date.firstOfMonth,
            to: nil,
            count: count,
            page: page
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    self.objectWillChange.send() // TODO: Remove this hack for updating dictionary values
                    return
                case .failure(let error):
                    print("Error loading transactions: \(error.name)")
                    self.transactions[requestId] = .failure(error)
                }
            }, receiveValue: { (transactions) in
                let groupedTransactions = OrderedDictionary<String,[Transaction]>(grouping: transactions, by: { $0.date.toLocaleString() })
                self.transactions[requestId] = .success(groupedTransactions)
            })
        
        return requestId
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
                self.transactions = ["": .failure(.loading)]
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
                self.transactions = ["": .failure(.loading)]
            })
    }
    
    func sum(budgetId: String? = nil, categoryId: String? = nil, from: Date? = nil, to: Date? = nil) -> String {
        let sumId = "\(String(describing: budgetId)):\(String(describing: categoryId)):\(String(describing: from)):\(String(describing: to))"
        self.sums[sumId] = .failure(.loading)
        self.sumRequests[sumId] = self.transactionRepository.sumTransactions(budgetId: budgetId, categoryId: categoryId, from: from, to: to)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.sumRequests.removeValue(forKey: sumId)
                    return
                case .failure(let error):
                    self.sums[sumId] = .failure(error)
                }
            }, receiveValue: { (sum) in
                self.sums[sumId] = .success(sum)
            })
        return sumId
    }
    
    func clearSelectedTransaction() {
        self.transaction = .failure(.unknown)
    }
    
    func reset() {
        self.transaction = .failure(.unknown)
        self.transactions = ["": .failure(.loading)]
    }
        
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
}
