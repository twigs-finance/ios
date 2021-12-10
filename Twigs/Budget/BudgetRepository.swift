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
    func getBudget(_ id: String) -> AnyPublisher<Budget, NetworkError>
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError>
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError>
    func deleteBudget(_ id: String) -> AnyPublisher<Empty, NetworkError>
}

#if DEBUG
class MockBudgetRepository: BudgetRepository {
    static let budget = Budget(
        id: "1",
        name: "Test Budget",
        description: "A mock budget used for testing",
        currencyCode: "USD"
    )
    
    func getBudgets(count: Int?, page: Int?) -> AnyPublisher<[Budget], NetworkError> {
        return Result.Publisher([MockBudgetRepository.budget]).eraseToAnyPublisher()
    }
    
    func getBudget(_ id: String) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(MockBudgetRepository.budget).eraseToAnyPublisher()
    }
    
    func newBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(MockBudgetRepository.budget).eraseToAnyPublisher()
    }
    
    func updateBudget(_ budget: Budget) -> AnyPublisher<Budget, NetworkError> {
        return Result.Publisher(Budget(
            id: "1",
            name: "Test Budget",
            description: "A mock budget used for testing",
            currencyCode: "USD"
        )).eraseToAnyPublisher()
    }
    
    func deleteBudget(_ id: String) -> AnyPublisher<Empty, NetworkError> {
        return Result.Publisher(Empty()).eraseToAnyPublisher()
    }
}
#endif
