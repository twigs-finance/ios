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
import TwigsCore

@MainActor
class TransactionDataStore: ObservableObject {
    @Published var transactions: AsyncData<OrderedDictionary<String, [Transaction]>> = .empty
    @Published var transaction: AsyncData<Transaction> = .empty {
        didSet {
            if case let .success(transaction) = self.transaction {
                self.selectedTransaction = transaction
            } else if case .empty = self.transaction {
                self.selectedTransaction = nil
            }
        }
    }
    @Published var selectedTransaction: Transaction? = nil
    private var budgetId: String = ""
    private var categoryId: String? = nil
    private var from: Date? = nil
    private var count: Int? = nil
    private var page: Int? = nil
    
    func getTransactions(_ budgetId: String, categoryId: String? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) async {
        self.budgetId = budgetId
        self.categoryId = categoryId
        self.from = from
        self.count = count
        self.page = page
        await self.getTransactions()
    }
    
    func getTransactions() async {
        self.transactions = .loading
        do {
            var categoryIds: [String] = []
            if let categoryId = categoryId {
                categoryIds.append(categoryId)
            }
            let transactions = try await self.transactionRepository.getTransactions(
                budgetIds: [budgetId],
                categoryIds: categoryIds,
                from: from ?? Date.firstOfMonth,
                to: nil,
                count: count,
                page: page
            )
            let groupedTransactions = OrderedDictionary<String,[Transaction]>(grouping: transactions, by: { $0.date.toLocaleString() })
            self.transactions = .success(groupedTransactions)
        } catch {
            self.transactions = .error(error)
        }
    }
    
    func saveTransaction(_ transaction: Transaction) async {
        self.transaction = .saving(transaction)
        do {
            var savedTransaction: Transaction
            if (transaction.id != "") {
                savedTransaction = try await self.transactionRepository.updateTransaction(transaction)
            } else {
                savedTransaction = try await self.transactionRepository.createTransaction(transaction)
            }
            self.transaction = .success(savedTransaction)
            await getTransactions()
        } catch {
            self.transaction = .error(error, transaction)
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async {
        self.transaction = .loading
        do {
            try await self.transactionRepository.deleteTransaction(transaction.id)
            self.transaction = .empty
        } catch {
            self.transaction = .error(error, transaction)
        }
    }
    
    func editTransaction(_ transaction: Transaction) {
        self.transaction = .editing(transaction)
    }
    
    func cancelEdit() {
        if let transaction = self.selectedTransaction {
            self.transaction = .success(transaction)
        } else {
            self.transaction = .empty
        }
    }
    
    func clearSelectedTransaction() {
        self.transaction = .empty
    }
        
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
}
