//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class TwigsInMemoryCacheService: TwigsApiService {
    var budgets = Set<Budget>()
    var categories = Set<Category>()
    var transactions = Set<Transaction>()
    
    // MARK: Budgets
    override func getBudgets(count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Budget], NetworkError> {
        let results = budgets.sorted { (first, second) -> Bool in
            return first.name < second.name
        }
        if results.isEmpty {
            return super.getBudgets(count: count, page: page).map { (budgets: [Budget]) in
                self.addBudgets(budgets)
                return budgets
            }.eraseToAnyPublisher()
        }
        return Result.Publisher(.success(results.slice(count: count, page: page))).eraseToAnyPublisher()
    }
    
    override func getBudget(_ id: String) -> AnyPublisher<Budget, NetworkError> {
        guard let budget = budgets.first(where: { $0.id == id }) else {
            return super.getBudget(id).map { budget in
                self.addBudget(budget)
                return budget
            }.eraseToAnyPublisher()
        }
        return Result.Publisher(.success(budget)).eraseToAnyPublisher()
    }
    
    func addBudgets(_ budgets: [Budget]) {
        budgets.forEach { addBudget($0) }
    }
    
    func addBudget(_ budget: Budget) {
        self.budgets.insert(budget)
    }
    
    // MARK: Categories
    override func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Category], NetworkError> {
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
            return super.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page).map { (categories: [Category]) in
                self.addCategories(categories)
                return categories
            }.eraseToAnyPublisher()
        }
        let sortedResults = results.sorted { $0.title < $1.title }
        return Result.Publisher(.success(sortedResults.slice(count: count, page: page))).eraseToAnyPublisher()
    }
    
    override func getCategory(_ id: String) -> AnyPublisher<Category, NetworkError> {
        guard let category = categories.first(where: { $0.id == id }) else {
            return super.getCategory(id).map { category in
                self.addCategory(category)
                return category
            }.eraseToAnyPublisher()
        }
        return Result.Publisher(.success(category)).eraseToAnyPublisher()
    }
    
    func addCategories(_ categories: [Category]) {
        categories.forEach { addCategory($0) }
    }
    
    func addCategory(_ category: Category) {
        self.categories.insert(category)
    }
    
    override func createCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return super.createCategory(category).map {
            self.categories.insert(category)
            return $0
        }.eraseToAnyPublisher()
    }
    
    override func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return super.updateCategory(category).map {
            self.removeCategory(category.id)
            self.categories.insert(category)
            return $0
        }.eraseToAnyPublisher()
    }
    
    override func deleteCategory(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return super.deleteCategory(id).map {
            self.removeCategory(id)
            return $0
        }.eraseToAnyPublisher()
    }

    func removeCategory(_ id: String) {
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
