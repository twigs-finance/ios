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
    var budgets: Result<[Budget], NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    var budget: Result<Budget, NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
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
                self.budgets = .success(budgets)
            })
    }
    
    func getBudget(_ id: String) {
        self.budget = .failure(.loading)
        
        self.currentRequest = self.budgetRepository.getBudget(id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.budget = .failure(error)
                    return
                }
            }, receiveValue: { (budget) in
                self.budget = .success(budget)
            })
    }
    
    init(_ budgetRepository: BudgetRepository) {
        self.budgetRepository = budgetRepository
    }
    
    private let budgetRepository: BudgetRepository
    // Needed since the default implementation is currently broken
    let objectWillChange = ObservableObjectPublisher()
}
