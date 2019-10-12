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
}

class NetworkCategoryRepository: CategoryRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getCategories(budgetId: Int?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return apiService.getCategories(budgetId: budgetId, count: count, page: page)
    }
}

#if DEBUG

class MockCategoryRepository: CategoryRepository {
    func getCategories(budgetId: Int?, count: Int?, page: Int?) -> AnyPublisher<[Category], NetworkError> {
        return Result.Publisher([]).eraseToAnyPublisher()
    }
}

#endif
