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

class TransactionDataStore: AsyncObservableObject {
    @Published var transactions: AsyncData<OrderedDictionary<String, [Transaction]>> = .empty
    @Published var transaction: AsyncData<Transaction> = .empty

    func getTransactions(_ budgetId: String, categoryId: String? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) async {
        try await load {
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
            self.transactions = groupedTransactions
        }
    }
    
    func saveTransaction(_ transaction: Transaction) async {
        try await load {
            if (transaction.id != "") {
                self.transaction = try await self.transactionRepository.updateTransaction(transaction)
            } else {
                self.transaction = try await self.transactionRepository.createTransaction(transaction)
            }
        }
    }
    
    func deleteTransaction(_ transactionId: String) async {
        try await load {
            try await self.transactionRepository.deleteTransaction(transactionId)
            self.transaction = nil
        }
    }
    
    func clearSelectedTransaction() {
        self.transaction = nil
    }
        
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
}
