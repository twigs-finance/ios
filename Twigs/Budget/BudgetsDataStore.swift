//
//  BudgetsDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class BudgetsDataStore: ObservableObject {
    private let budgetRepository: BudgetRepository
    private let categoryRepository: CategoryRepository
    private let transactionRepository: TransactionRepository
    private var currentRequest: AnyCancellable? = nil
    @Published var budgets: Result<[Budget], NetworkError> = .failure(.loading)
    @Published var budget: Result<Budget, NetworkError>? = .failure(.loading) {
        didSet {
            if case let .success(budget) = self.budget {
                UserDefaults.standard.set(budget.id, forKey: LAST_BUDGET)
                self.showBudgetSelection = false
                loadOverview(budget)
            }
        }
    }
    @Published var overview: Result<BudgetOverview, NetworkError> = .failure(.loading)
    @Published var showBudgetSelection: Bool = true
    
    init(budgetRepository: BudgetRepository, categoryRepository: CategoryRepository, transactionRepository: TransactionRepository) {
        self.budgetRepository = budgetRepository
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository
        self.getBudgets(count: nil, page: nil)
    }
        
    func getBudgets(count: Int? = nil, page: Int? = nil) {
        self.budgets = .failure(.loading)
        
        self.currentRequest = self.budgetRepository.getBudgets(count: count, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    switch error {
                    case .jsonParsingFailed(let wrappedError):
                        if let networkError = wrappedError as? NetworkError {
                            print("failed to load budgets: \(networkError.name)")
                        }
                    default:
                        print("failed to load budgets: \(error.name)")
                    }
                    
                    self.budgets = .failure(error)
                    return
                }
            }, receiveValue: { (budgets) in
                self.budgets = .success(budgets.sorted(by: { $0.name < $1.name }))
                if case .success(_) = self.budget {
                    // Don't do anything here
                } else {
                    if let id = UserDefaults.standard.string(forKey: LAST_BUDGET) {
                        if let budget = budgets.first(where: { $0.id == id }) {
                            self.budget = .success(budget)
                        } else {
                            self.budget = nil
                        }
                    } else {
                        if let budget = budgets.first {
                            self.budget = .success(budget)
                        } else {
                            self.budget = nil
                        }
                    }
                }
            })
    }
    
    func loadOverview(_ budget: Budget) {
        self.overview = .failure(.loading)
        self.currentRequest = self.transactionRepository.sumTransactions(budgetId: budget.id, categoryId: nil, from: nil, to: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                case .failure(let error):
                    switch error {
                    case .jsonParsingFailed(let wrappedError):
                        if let networkError = wrappedError as? NetworkError {
                            print("failed to load budget overview: \(networkError.name)")
                        }
                    default:
                        print("failed to load budget overview: \(error.name)")
                    }
                    self.budgets = .failure(error)
                    self.currentRequest = nil
                    return
                }
            }, receiveValue: { (response) in
                self.sumCategories(budget: budget, balance: response.balance)
            })
    }
    
    private func sumCategories(budget: Budget, balance: Int) {
        self.currentRequest = self.categoryRepository.getCategories(budgetId: budget.id, expense: nil, archived: false, count: nil, page: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    switch error {
                    case .jsonParsingFailed(let wrappedError):
                        if let networkError = wrappedError as? NetworkError {
                            print("failed to load budget overview: \(networkError.name)")
                        }
                    default:
                        print("failed to load budget overview: \(error.name)")
                    }
                    self.budgets = .failure(error)
                    return
                }
            }, receiveValue: { (categories) in
                var budgetOverview = BudgetOverview(budget: budget, balance: balance)
                budgetOverview.expectedIncome = 0
                budgetOverview.expectedIncome = 0
                budgetOverview.actualIncome = 0
                budgetOverview.actualIncome = 0
                var categorySums: [AnyPublisher<CategoryBalance, NetworkError>] = []
                categories.forEach { category in
                    if category.expense {
                        budgetOverview.expectedExpenses += category.amount
                    } else {
                        budgetOverview.expectedIncome += category.amount
                    }
                    categorySums.append(self.transactionRepository.sumTransactions(budgetId: nil, categoryId: category.id, from: nil, to: nil).map {
                        CategoryBalance(category: category, balance: $0.balance)
                    }.eraseToAnyPublisher())
                }
                
                self.currentRequest = Publishers.MergeMany(categorySums)
                    .collect()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { status in
                        switch status {
                        case .finished:
                            self.currentRequest = nil
                            return
                        case .failure(let error):
                            switch error {
                            case .jsonParsingFailed(let wrappedError):
                                if let networkError = wrappedError as? NetworkError {
                                    print("failed to load budget overview: \(networkError.name)")
                                }
                            default:
                                print("failed to load budget overview: \(error.name)")
                            }
                            self.overview = .failure(error)
                            return
                        }
                    }, receiveValue: {
                        $0.forEach { categoryBalance in
                            if categoryBalance.category.expense {
                                budgetOverview.actualExpenses += abs(categoryBalance.balance)
                            } else {
                                budgetOverview.actualIncome += categoryBalance.balance
                            }
                        }
                        self.overview = .success(budgetOverview)
                    })
            })
    }
    
    func selectBudget(_ budget: Budget) {
        self.budget = .success(budget)
    }
}

private let LAST_BUDGET = "LAST_BUDGET"
