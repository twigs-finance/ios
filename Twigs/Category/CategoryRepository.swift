//
//  CategoryRepository.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

#if DEBUG
class MockCategoryRepository: CategoryRepository {
    static let category = TwigsCore.Category(
        budgetId: MockBudgetRepository.budget.id,
        id: "3",
        title: "Test Category",
        description: "This is a test category to help with testing",
        amount: 10000,
        expense: true,
        archived: false
    )
    
    func getCategories(budgetId: String?, expense: Bool?, archived: Bool?, count: Int?, page: Int?) async throws -> [TwigsCore.Category] {
        return [MockCategoryRepository.category]
    }
    
    func getCategory(_ categoryId: String) async throws -> TwigsCore.Category {
        return MockCategoryRepository.category
    }
    
    func createCategory(_ category: TwigsCore.Category) async throws -> TwigsCore.Category {
        return MockCategoryRepository.category
    }

    func updateCategory(_ category: TwigsCore.Category) async throws -> TwigsCore.Category {
        return MockCategoryRepository.category
    }
    
    func deleteCategory(_ id: String) async throws {
        
    }
}

#endif
