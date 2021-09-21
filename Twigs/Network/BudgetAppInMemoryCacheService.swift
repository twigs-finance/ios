//
//  BudgetApiService.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class BudgetAppInMemoryCacheService {
    var budgets = Set<Budget>()
    var categories = Set<Category>()
    var transactions = Set<Transaction>()
    
    // MARK: Budgets
    func getBudgets(count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Budget], NetworkError>? {
        let results = budgets.sorted { (first, second) -> Bool in
            return first.name < second.name
        }
        if results.isEmpty {
            return nil
        }
        return Result.Publisher(.success(results.slice(count: count, page: page))).eraseToAnyPublisher()
    }
    
    func getBudget(_ id: String) -> AnyPublisher<Budget, NetworkError>? {
        guard let budget = budgets.first(where: { $0.id == id }) else {
            return nil
        }
        return Result.Publisher(.success(budget)).eraseToAnyPublisher()
    }
    
    func getBudgetBalance(_ id: String) -> AnyPublisher<Int, NetworkError>? {
        return nil
    }
    
    func addBudgets(_ budgets: [Budget]) {
        budgets.forEach { addBudget($0) }
    }
    
    func addBudget(_ budget: Budget) {
        self.budgets.insert(budget)
    }
    
    // MARK: Transactions
    func getTransactions(
        budgetIds: [Int]? = nil,
        categoryIds: [Int]? = nil,
        from: Date? = nil,
        to: Date? = nil,
        count: Int? = nil,
        page: Int? = nil
    ) -> AnyPublisher<[Transaction], NetworkError>? {
        return nil
    }
    
    func getTransaction(_ id: String) -> AnyPublisher<Transaction, NetworkError>? {
        return nil
    }
    
    // MARK: Categories
    func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Category], NetworkError>? {
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
            return nil
        }
        let sortedResults = results.sorted { $0.title < $1.title }
        return Result.Publisher(.success(sortedResults.slice(count: count, page: page))).eraseToAnyPublisher()
    }
    
    func getCategory(_ id: String) -> AnyPublisher<Category, NetworkError>? {
        guard let category = categories.first(where: { $0.id == id }) else {
            return nil
        }
        return Result.Publisher(.success(category)).eraseToAnyPublisher()
    }
    
    func getCategoryBalance(_ id: String) -> AnyPublisher<Int, NetworkError>? {
        return nil
    }
    
    func addCategories(_ categories: [Category]) {
        categories.forEach { addCategory($0) }
    }
    
    func addCategory(_ category: Category) {
        self.categories.insert(category)
    }

    
    // MARK: Users
    func getUser(id: String) -> AnyPublisher<User, NetworkError>? {
        return nil
    }
    
    func getUsers(count: Int? = nil, page: Int? = nil) -> AnyPublisher<[User], NetworkError>? {
        return nil
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
