//
//  BudgetRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class BudgetRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getBudgets() -> AnyPublisher<[Budget], NetworkError> {
        return apiService.getBudgets()
    }
}
