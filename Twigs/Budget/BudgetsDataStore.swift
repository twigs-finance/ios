//
//  BudgetsDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

private let LAST_BUDGET = "LAST_BUDGET"

@MainActor
class BudgetsDataStore: ObservableObject {
    private let budgetRepository: BudgetRepository
    private let categoryRepository: CategoryRepository
    private let transactionRepository: TransactionRepository
    @Published var budgets: AsyncData<[Budget]> = .empty
    @Published var budget: AsyncData<Budget> = .empty {
        didSet {
            self.overview = .empty
            if case let .success(budget) = self.budget {
                UserDefaults.standard.set(budget.id, forKey: LAST_BUDGET)
                self.showBudgetSelection = false
                Task {
                    await loadOverview(budget)
                }
            }
        }
    }
    @Published var overview: AsyncData<BudgetOverview> = .empty
    @Published var showBudgetSelection: Bool = true
    
    init(budgetRepository: BudgetRepository, categoryRepository: CategoryRepository, transactionRepository: TransactionRepository) {
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository
    }
        
    func getBudgets(count: Int? = nil, page: Int? = nil) async {
        // TODO: Find some way to extract this to a generic function
        self.budgets = .loading
        do {
            let budgets = try await self.budgetRepository.getBudgets(count: count, page: page).sorted(by: { $0.name < $1.name })
            self.budgets = .success(budgets)
            if self.budget != .empty {
                return
            }
            if let id = UserDefaults.standard.string(forKey: LAST_BUDGET), let lastBudget = budgets.first(where: { $0.id == id }) {
                self.budget = .success(lastBudget)
            } else {
                if let budget = budgets.first {
                    self.budget = .success(budget)
                }
            }
        } catch {
            self.budgets = .error(error)
        }
    }
    
    func loadOverview(_ budget: Budget) async {
        self.overview = .loading
        do {
            let budgetBalance = try await self.transactionRepository.sumTransactions(budgetId: budget.id, categoryId: nil, from: nil, to: nil)
            let categories = try await self.categoryRepository.getCategories(budgetId: budget.id, expense: nil, archived: false, count: nil, page: nil)
            var budgetOverview = BudgetOverview(budget: budget, balance: budgetBalance.balance)
            try await withThrowingTaskGroup(of: (TwigsCore.Category, BalanceResponse).self) { group in
                for category in categories {
                    group.addTask {
                        return (category, try await self.transactionRepository.sumTransactions(budgetId: nil, categoryId: category.id, from: nil, to: nil))
                    }
                }

                for try await (category, response) in group {
                    if category.expense {
                        budgetOverview.expectedExpenses += category.amount
                    } else {
                        budgetOverview.expectedIncome += category.amount
                    }
                    
                    if category.expense {
                        budgetOverview.actualExpenses += abs(response.balance)
                    } else {
                        budgetOverview.actualIncome += response.balance
                    }
                }
            }
            self.overview = .success(budgetOverview)
        } catch {
            self.overview = .error(error)
        }
    }
    
    func selectBudget(_ budget: Budget) {
        self.budget = .success(budget)
    }
}
