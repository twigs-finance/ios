//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

class TwigsInMemoryCacheService: TwigsApiService {
    private var budgets = Set<Budget>()
    private var categories = Set<TwigsCore.Category>()
    private var transactions = Set<Transaction>()
    
    public init() {
        super.init(RequestHelper())
    }

    // MARK: Budgets
    override func getBudgets(count: Int? = nil, page: Int? = nil) async throws -> [Budget] {
        let results = budgets.sorted { (first, second) -> Bool in
            return first.name < second.name
        }
        if results.isEmpty {
            let budgets = try await super.getBudgets(count: count, page: page)
            self.addBudgets(budgets)
            return budgets
        }
        return results.slice(count: count, page: page)
    }
    
    override func getBudget(_ id: String) async throws -> Budget {
        guard let budget = budgets.first(where: { $0.id == id }) else {
            let budget = try await super.getBudget(id)
            self.addBudget(budget)
            return budget
        }
        return budget
    }
    
    override func newBudget(_ budget: Budget) async throws -> Budget {
        let newBudget = try await super.newBudget(budget)
        self.addBudget(newBudget)
        return newBudget
    }
    
    override func updateBudget(_ budget: Budget) async throws -> Budget {
        let newBudget = try await super.updateBudget(budget)
        if let index = self.budgets.firstIndex(where: {$0.id == budget.id}) {
            self.budgets.remove(at: index)
        }
        self.addBudget(newBudget)
        return newBudget
    }
    
    override func deleteBudget(_ id: String) async throws {
        try await super.deleteBudget(id)
        if let index = self.budgets.firstIndex(where: {$0.id == id}) {
            self.budgets.remove(at: index)
        }
    }
    
    private func addBudgets(_ budgets: [Budget]) {
        budgets.forEach { addBudget($0) }
    }
    
    private func addBudget(_ budget: Budget) {
        self.budgets.insert(budget)
    }
    
    // MARK: Categories
    override func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) async throws -> [TwigsCore.Category] {
        var results = categories
        if budgetId != nil {
            results = categories.filter { $0.budgetId == budgetId }
        }
        if expense != nil {
            results = results.filter { $0.expense == expense }
        }
        if archived != nil {
            results = results.filter { $0.archived == archived }
        }
        if results.isEmpty {
            let categories = try await super.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page)
            self.addCategories(categories)
            return categories
        }
        let sortedResults = results.sorted { $0.title < $1.title }
        return sortedResults.slice(count: count, page: page)
    }
    
    override func getCategory(_ id: String) async throws -> TwigsCore.Category {
        guard let category = categories.first(where: { $0.id == id }) else {
            let category = try await super.getCategory(id)
            self.addCategory(category)
            return category
        }
        return category
    }
    
    private func addCategories(_ categories: [TwigsCore.Category]) {
        categories.forEach { addCategory($0) }
    }
    
    private func addCategory(_ category: TwigsCore.Category) {
        self.categories.insert(category)
    }
    
    override func createCategory(_ category: TwigsCore.Category) async throws -> TwigsCore.Category {
        let newCategory = try await super.createCategory(category)
        self.categories.insert(newCategory)
        return newCategory
    }
    
    override func updateCategory(_ category: TwigsCore.Category) async throws -> TwigsCore.Category {
        let newCategory = try await super.updateCategory(category)
        self.removeCategory(newCategory.id)
        self.categories.insert(newCategory)
        return newCategory
    }
    
    override func deleteCategory(_ id: String) async throws {
        try await super.deleteCategory(id)
        self.removeCategory(id)
    }
    
    private func removeCategory(_ id: String) {
        if let index = self.categories.firstIndex(where: { $0.id == id }) {
            self.categories.remove(at: index)
        }
    }
}

/**
 * Determines which slice of the array should be returned based on the count and page parameters
 */
private func calculateStartAndEndIndices(count: Int, page: Int?) -> (start: Int, end: Int?) {
    let end = count * (page ?? 1)
    let start = max(end - count, 0)
    return (start, end)
}

extension Array {
    func slice(count: Int?, page: Int?) -> Array<Element> {
        if count == nil {
            return self
        }
        let indices: (Int, Int?) = calculateStartAndEndIndices(count: count!, page: page)
        return Array(self[indices.0..<Swift.min((indices.1 ?? self.count), self.count)])
    }
}
