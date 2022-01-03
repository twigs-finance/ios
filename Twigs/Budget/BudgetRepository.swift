//
//  BudgetRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

#if DEBUG
class MockBudgetRepository: BudgetRepository {
    static let budget = Budget(
        id: "1",
        name: "Test Budget",
        description: "A mock budget used for testing",
        currencyCode: "USD"
    )
    
    func getBudgets(count: Int?, page: Int?) async throws -> [Budget] {
        return [MockBudgetRepository.budget]
    }
    
    func getBudget(_ id: String) async throws -> Budget {
        return MockBudgetRepository.budget
    }
    
    func newBudget(_ budget: Budget) async throws -> Budget {
        return MockBudgetRepository.budget
    }
    
    func updateBudget(_ budget: Budget) async throws -> Budget {
        return Budget(
            id: "1",
            name: "Test Budget",
            description: "A mock budget used for testing",
            currencyCode: "USD"
        )
    }
    
    func deleteBudget(_ id: String) async throws {
    }
}
#endif
