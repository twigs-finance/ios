//
//  CategoryRepository.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

protocol CategoryRepository {
    func getCategories(budgetId: String?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError>
    func getCategory(_ categoryId: String) -> AnyPublisher<Category, NetworkError>
}

class NetworkCategoryRepository: CategoryRepository {
    let apiService: BudgetAppApiService
    let cacheService: BudgetAppInMemoryCacheService?

    init(_ apiService: BudgetAppApiService, cacheService: BudgetAppInMemoryCacheService? = nil) {
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    func getCategories(budgetId: String?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        if let categories = cacheService?.getCategories(budgetId: budgetId, count: count, page: page) {
            print("Returning categories from cache")
            return categories
        }
        
        print("No cached categories, fetching from network")
        return apiService.getCategories(budgetId: budgetId, count: count, page: page).map { (categories: [Category]) in
            self.cacheService?.addCategories(categories)
            return categories
        }.eraseToAnyPublisher()
    }
    
    func getCategory(_ categoryId: String) -> AnyPublisher<Category, NetworkError> {
        if let category = cacheService?.getCategory(categoryId) {
            print("Returning category from cache")
            return category
        }
        print("Category with ID \(categoryId) not cached, returning from network")
        return apiService.getCategory(categoryId).map { category in
            self.cacheService?.addCategory(category)
            return category
        }.eraseToAnyPublisher()
    }
}

#if DEBUG

class MockCategoryRepository: CategoryRepository {
    static let category = Category(
        budgetId: MockBudgetRepository.budget.id,
        id: "3",
        title: "Test Category",
        description: "This is a test category to help with testing",
        amount: 10000,
        expense: true
    )
    
    func getCategories(budgetId: String?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return Result.Publisher([MockCategoryRepository.category]).eraseToAnyPublisher()
    }
    
    func getCategory(_ categoryId: String) -> AnyPublisher<Category, NetworkError> {
        return Result.Publisher(MockCategoryRepository.category).eraseToAnyPublisher()
    }
}

#endif
