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
import TwigsCore

@MainActor
class RecurringTransactionDataStore: AsyncObservableObject {
    private let repository: RecurringTransactionsRepository
    @Published var transactions: AsyncData<[RecurringTransaction]> = .empty
    @Published var transaction: AsyncData<RecurringTransaction> = .empty {
        didSet {
            if case let .success(transaction) = self.transaction {
                self.selectedTransaction = transaction
            } else if case .empty = transaction {
                self.selectedTransaction = nil
            }
        }
    }
    @Published var selectedTransaction: RecurringTransaction? = nil
    
    init(_ repository: RecurringTransactionsRepository) {
        self.repository = repository
    }
    
    func getRecurringTransactions(_ budgetId: String) async {
        self.transactions = .loading
        do {
            let transactions = try await self.repository.getRecurringTransactions(budgetId)
            self.transactions = .success(transactions.sorted(by: { $0.title < $1.title }))
        } catch {
            self.transactions = .error(error)
        }
    }
    
    func saveRecurringTransaction(_ transaction: RecurringTransaction) async {
        self.transaction = .loading
        do {
            var savedTransaction: RecurringTransaction
            if (transaction.id != "") {
                savedTransaction = try await self.repository.updateRecurringTransaction(transaction)
            } else {
                savedTransaction = try await self.repository.createRecurringTransaction(transaction)
            }
            self.transaction = .success(savedTransaction)
            if case var .success(transactions) = self.transactions {
                transactions = transactions.filter(withoutId: savedTransaction.id)
                transactions.append(savedTransaction)
                self.transactions = .success(transactions.sorted(by: { $0.title < $1.title }))
            }
        } catch {
            self.transactions = .error(error)
        }
    }
    
    func deleteRecurringTransaction(_ transaction: RecurringTransaction) async {
        self.transactions = .loading
        do {
            try await self.repository.deleteRecurringTransaction(transaction.id)
            self.transaction = .empty
            if case let .success(transactions) = self.transactions {
                self.transactions = .success(transactions.filter(withoutId: transaction.id))
            }
        } catch {
            self.transaction = .error(error, transaction)
        }
    }
    
    func clearSelectedRecurringTransaction() {
        self.transaction = .empty
    }
}
