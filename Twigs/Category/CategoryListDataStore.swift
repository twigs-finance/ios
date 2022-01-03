//
//  CategoryListDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

@MainActor
class CategoryListDataStore: ObservableObject {
    @Published var categories: AsyncData<[TwigsCore.Category]> = .empty
    @Published var category: AsyncData<TwigsCore.Category> = .empty
    
    func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = false, count: Int? = nil, page: Int? = nil) async {
        self.categories = .loading
        do {
            let categories = try await categoryRepository.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page)
            self.categories = .success(categories)
        } catch {
            self.categories = .error(error)
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
            if case let .success(categories) = self.categories {
                var updatedCategories = categories.filter(withoutId: category.id)
                updatedCategories.append(savedCategory)
                self.categories = .success(updatedCategories.sorted(by: { $0.title < $1.title }))
            }
        } catch {
            self.category = .error(error, category)
        }
    }
    
    func delete(_ category: TwigsCore.Category) async {
        self.category = .loading
        do {
            try await self.categoryRepository.deleteCategory(category.id)
            self.category = .empty
            if case let .success(categories) = self.categories {
                self.categories = .success(categories.filter(withoutId: category.id))
            }
        } catch {
            self.category = .error(error, category)
        }
    }

    func selectCategory(_ category: TwigsCore.Category) {
        self.category = .success(category)
    }
    
    func clearSelectedCategory() {
        self.category = .empty
    }
    
    private let categoryRepository: CategoryRepository
    init(_ categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
}
