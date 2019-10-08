//
//  TransactionDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class TransactionDataStore: ObservableObject {
    var transactions: Result<[Transaction], NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func getTransactions(_ category: Category? = nil) {
        self.transactions = .failure(.loading)
        
        var categoryIds: [Int] = []
        if category != nil {
            categoryIds.append(category!.id!)
        }
        _ = self.transactionRepository.getTransactions(categoryIds: categoryIds, from: Date(timeIntervalSince1970: 0))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self.transactions = .failure(error)
                }
            }, receiveValue: { (transactions) in
                self.transactions = .success(transactions)
            })
    }
    
    let objectWillChange = ObservableObjectPublisher()
    private let transactionRepository: TransactionRepository
    init(_ transactionRepository: TransactionRepository, category: Category? = nil) {
        self.transactionRepository = transactionRepository
        self.getTransactions(category)
    }
}
