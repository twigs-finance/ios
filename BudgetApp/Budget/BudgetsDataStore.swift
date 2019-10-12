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
        
        _ = self.budgetRepository.getBudgets(count: count, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (status) in
                switch status {
                case .finished:
                    return
                case .failure(let error):
                    self.budgets = .failure(error)
                    return
                }
            }, receiveValue: { (budgets) in
                self.budgets = .success(budgets)
            })
    }
    
    init(_ budgetRepository: BudgetRepository) {
        self.budgetRepository = budgetRepository
    }
    
    private let budgetRepository: BudgetRepository
    // Needed since the default implementation is currently broken
    let objectWillChange = ObservableObjectPublisher()
}
