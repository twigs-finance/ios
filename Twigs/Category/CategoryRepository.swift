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
