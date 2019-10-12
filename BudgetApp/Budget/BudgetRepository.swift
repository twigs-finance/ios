//
//  BudgetRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

protocol BudgetRepository {
    func getBudgets(count: Int?, page: Int?) -> AnyPublisher<[Budget], NetworkError>
    func getBudget(_ id: Int) -> AnyPublisher<Budget, NetworkError>
    func getBudgetBalance(_ id: Int) -> AnyPublisher<Int, NetworkError>
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError>
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError>
    func deleteBudget(_ id: Int) -> AnyPublisher<Empty, NetworkError>
}

class NetworkBudgetRepository: BudgetRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getBudgets(count: Int?, page: Int?) -> AnyPublisher<[Budget], NetworkError> {
        return apiService.getBudgets(count: count, page: page)
    }
    
    func getBudget(_ id: Int) -> AnyPublisher<Budget, NetworkError> {
        return apiService.getBudget(id)
    }
    
    func getBudgetBalance(_ id: Int) -> AnyPublisher<Int, NetworkError> {
        return apiService.getBudgetBalance(id)
    }
    
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return apiService.newBudget(budget)
    }
    
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return apiService.updateBudget(budget)
    }
    
    func deleteBudget(_ id: Int) -> AnyPublisher<Empty, NetworkError> {
        return apiService.deleteBudget(id)
    }
}

#if DEBUG

class MockBudgetRepository: BudgetRepository {
    func getBudgets(count: Int?, page: Int?) -> AnyPublisher<[Budget], NetworkError> {
        return Result.Publisher([Budget(
            id: 1,
            name: "Test Budget",
            description: "A mock budget used for testing",
            users: []
            )]).eraseToAnyPublisher()
    }
    
    func getBudget(_ id: Int) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(Budget(
            id: 1,
            name: "Test Budget",
            description: "A mock budget used for testing",
            users: []
            )).eraseToAnyPublisher()
    }
    
    func getBudgetBalance(_ id: Int) -> AnyPublisher<Int, NetworkError> {
        return Result.Publisher(10000).eraseToAnyPublisher()
    }
    
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(Budget(
            id: 1,
            name: "Test Budget",
            description: "A mock budget used for testing",
            users: []
            )).eraseToAnyPublisher()
    }
    
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(Budget(
            id: 1,
            name: "Test Budget",
            description: "A mock budget used for testing",
            users: []
            )).eraseToAnyPublisher()
    }
    
    func deleteBudget(_ id: Int) -> AnyPublisher<Empty, NetworkError> {
        return Result.Publisher(Empty()).eraseToAnyPublisher()
    }
}

#endif
