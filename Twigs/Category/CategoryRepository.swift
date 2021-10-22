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
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError>
    func getCategory(_ categoryId: String) -> AnyPublisher<Category, NetworkError>
    func createCategory(_ category: Category) -> AnyPublisher<Category, NetworkError>
    func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError>
    func deleteCategory(_ id: String) -> AnyPublisher<Empty, NetworkError>
}

class NetworkCategoryRepository: CategoryRepository {
    let apiService: TwigsApiService
    let cacheService: TwigsInMemoryCacheService?

    init(_ apiService: TwigsApiService, cacheService: TwigsInMemoryCacheService? = nil) {
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        if let categories = cacheService?.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page) {
            print("Returning categories from cache")
            return categories
        }
        
        print("No cached categories, fetching from network")
        return apiService.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page).map { (categories: [Category]) in
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
    
    func createCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return apiService.newCategory(category).map {
            self.cacheService?.addCategory($0)
            return $0
        }.eraseToAnyPublisher()
    }

    func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return apiService.updateCategory(category).map {
            self.cacheService?.updateCategory($0)
            return $0
        }.eraseToAnyPublisher()
    }
    
    func deleteCategory(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return apiService.deleteCategory(id).map {
            self.cacheService?.removeCategory(id)
            return $0
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
        expense: true,
        archived: false
    )
    
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return Result.Publisher([MockCategoryRepository.category]).eraseToAnyPublisher()
    }
    
    func getCategory(_ categoryId: String) -> AnyPublisher<Category, NetworkError> {
        return Result.Publisher(MockCategoryRepository.category).eraseToAnyPublisher()
    }
    
    func createCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return Result.Publisher(MockCategoryRepository.category).eraseToAnyPublisher()
    }

    func updateCategory(_ category: Category) -> AnyPublisher<Category, NetworkError> {
        return Result.Publisher(MockCategoryRepository.category).eraseToAnyPublisher()
    }
    
    func deleteCategory(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return Result.Publisher(.success(Empty())).eraseToAnyPublisher()
    }
}

#endif
