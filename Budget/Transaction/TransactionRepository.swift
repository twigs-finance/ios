//
//  TransactionRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class TransactionRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getTransactions(categoryIds: [Int]? = nil, from: Date? = nil, count: Int? = nil, page: Int? = nil) -> AnyPublisher<[Transaction], NetworkError> {
        return apiService.getTransactions(categoryIds: categoryIds, from: from, count: count, page: page)
    }
}
