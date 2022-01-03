//
//  CategoryDataStore.swift
//  Twigs
//
//  Created by William Brawner on 1/2/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

@MainActor
class CategoryDataStore: ObservableObject {
    @Published var sum: AsyncData<Int> = .empty
    let transactionRepository: TransactionRepository
    
    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }
    
    func sum(categoryId: String, from: Date? = nil, to: Date? = nil) async {
        self.sum = .loading
        do {
            let sum = try await self.transactionRepository.sumTransactions(budgetId: nil, categoryId: categoryId, from: from, to: to).balance
            self.sum = .success(sum)
        } catch {
            self.sum = .error(error)
        }
    }
    
    func save(_ category: TwigsCore.Category) async {
        self.category = .loading
        do {
            var savedCategory: TwigsCore.Category
            if category.id != "" {
                savedCategory = try await self.categoryRepository.updateCategory(category)
            } else {
                savedCategory = try await self.categoryRepository.createCategory(category)
            }
            self.category = .success(savedCategory)
        } catch {
            self.category = .error(error, category)
        }
    }
}
