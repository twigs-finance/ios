//
//  CategoryRepository.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class CategoryRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getCategories(budgetId: Int? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Category], NetworkError> {
        return apiService.getCategories(budgetId: budgetId, count: count, page: page)
    }
}
