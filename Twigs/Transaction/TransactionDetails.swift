//
//  TransactionDetail.swift
//  Twigs
//
//  Created by William Brawner on 1/4/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

@MainActor
class TransactionDetails: ObservableObject {
    @Published var category: AsyncData<TwigsCore.Category> = .empty
    @Published var budget: AsyncData<Budget> = .empty
    @Published var user: AsyncData<User> = .empty
    let budgetRepository: BudgetRepository
    let categoryRepository: CategoryRepository
    let userRepository: UserRepository
    
    init(budgetRepository: BudgetRepository, categoryRepository: CategoryRepository, userRepository: UserRepository) {
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.userRepository = userRepository
    }
    
    func loadDetails(_ transaction: TwigsCore.Transaction) async {
        Task {
            await loadBudget(transaction.budgetId)
        }
        Task {
            if let categoryId = transaction.categoryId {
                await loadCategory(categoryId)
            }
        }
        Task {
            await loadUser(transaction.createdBy)
        }
    }
    
    private func loadBudget(_ id: String) async {
        self.budget = .loading
        do {
            let budget = try await budgetRepository.getBudget(id)
            self.budget = .success(budget)
        } catch {
            self.budget = .error(error)
        }
    }
    
    private func loadCategory(_ id: String) async {
        self.category = .loading
        do {
            let category = try await categoryRepository.getCategory(id)
            self.category = .success(category)
        } catch {
            self.category = .error(error)
        }
    }
    
    private func loadUser(_ id: String) async {
        self.user = .loading
        do {
            let user = try await userRepository.getUser(id)
            self.user = .success(user)
        } catch {
            self.user = .error(error)
        }
    }
}
