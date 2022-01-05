//
//  TransactionForm.swift
//  Twigs
//
//  Created by William Brawner on 1/4/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

class TransactionForm: ObservableObject {
    let budgetRepository: BudgetRepository
    let categoryRepository: CategoryRepository
    let transactionList: TransactionDataStore
    let transaction: TwigsCore.Transaction?
    let createdBy: String
    let transactionId: String
    @Published var title: String
    @Published var description: String
    @Published var date: Date
    @Published var amount: String
    @Published var type: TransactionType
    @Published var budgetId: String {
        didSet {
            updateCategories()
        }
    }
    @Published var categoryId: String
    
    @Published var budgets: AsyncData<[Budget]> = .empty
    @Published var categories: AsyncData<[TwigsCore.Category]> = .empty
    private var cachedCategories: [TwigsCore.Category] = []
    let showDelete: Bool
    
    init(
        budgetRepository: BudgetRepository,
        categoryRepository: CategoryRepository,
        transactionList: TransactionDataStore,
        createdBy: String,
        budgetId: String,
        categoryId: String? = nil,
        transaction: TwigsCore.Transaction? = nil
    ) {
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.budgetId = budgetId
        self.categoryId = categoryId ?? ""
        self.createdBy = createdBy
        self.transactionList = transactionList
        let baseTransaction = transaction ?? TwigsCore.Transaction(categoryId: categoryId, createdBy: createdBy, budgetId: budgetId)
        self.transaction = transaction
        self.transactionId = baseTransaction.id
        self.title = baseTransaction.title
        self.description = baseTransaction.description ?? ""
        self.date = baseTransaction.date
        self.amount = baseTransaction.amountString
        self.type = baseTransaction.type
        self.showDelete = !baseTransaction.id.isEmpty
    }
    
    func load() async {
        self.budgets = .loading
        self.categories = .loading
        var budgets: [Budget]
        do {
            budgets = try await budgetRepository.getBudgets(count: nil, page: nil)
            self.budgets = .success(budgets)
        } catch {
            self.budgets = .error(error)
        }
        do {
            let categories = try await categoryRepository.getCategories(budgetId: nil, expense: nil, archived: false, count: nil, page: nil)
            self.cachedCategories = categories
            updateCategories()
        } catch {
            self.categories = .error(error)
        }
    }
    
    func save() async {
        let amount = Double(self.amount) ?? 0.0
        await transactionList.saveTransaction(Transaction(
            id: transactionId,
            title: title,
            description: description,
            date: date,
            amount: Int(amount * 100.0),
            categoryId: categoryId,
            expense: type.toBool(),
            createdBy: createdBy,
            budgetId: budgetId
        ))
    }
    
    func delete() async {
        guard let transaction = self.transaction else {
            return
        }
        await transactionList.deleteTransaction(transaction)
    }
    
    private func updateCategories() {
        self.categories = .success(cachedCategories.filter {
            $0.budgetId == self.budgetId && $0.expense == self.type.toBool()
        })
    }
}
