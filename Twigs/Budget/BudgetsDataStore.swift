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
    private var currentRequest: AnyCancellable? = nil
    @Published var budgets: Result<[Budget], NetworkError> = .failure(.loading)
    @Published var budget: Budget? = nil {
        didSet {
            UserDefaults.standard.set(budget?.id, forKey: LAST_BUDGET)
        }
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
                if let id = UserDefaults.standard.string(forKey: LAST_BUDGET) {
                    if let budget = budgets.first(where: { $0.id == id }) {
                        self.budget = budget
                    }
                }
            })
    }
        
    init(_ budgetRepository: BudgetRepository) {
        self.budgetRepository = budgetRepository
    }
    
    private let budgetRepository: BudgetRepository
}

private let LAST_BUDGET = "LAST_BUDGET"
