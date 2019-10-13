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
    func getCategories(budgetId: Int?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError>
    func getCategory(_ categoryId: Int) -> AnyPublisher<Category, NetworkError>
}

class NetworkCategoryRepository: CategoryRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getCategories(budgetId: Int?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return apiService.getCategories(budgetId: budgetId, count: count, page: page)
    }
    
    func getCategory(_ categoryId: Int) -> AnyPublisher<Category, NetworkError> {
        return apiService.getCategory(categoryId)
    }
}

#if DEBUG

class MockCategoryRepository: CategoryRepository {
    static let category = Category(
        budgetId: MockBudgetRepository.budget.id!,
        id: 3,
        title: "Test Category",
        description: "This is a test category to help with testing",
        amount: 10000
    )
    
    func getCategories(budgetId: Int?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return Result.Publisher([MockCategoryRepository.category]).eraseToAnyPublisher()
    }
    
    func getCategory(_ categoryId: Int) -> AnyPublisher<Category, NetworkError> {
        return Result.Publisher(MockCategoryRepository.category).eraseToAnyPublisher()
    }
}

#endif
