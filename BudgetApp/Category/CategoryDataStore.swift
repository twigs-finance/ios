//
//  CategoryDataStore.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class CategoryDataStore: ObservableObject {
    private var currentRequest: AnyCancellable? = nil
    var categories: Result<[Category], NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    var category: Result<Category, NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func getCategories(budgetId: String? = nil, archived: Bool? = false, count: Int? = nil, page: Int? = nil) {
        self.categories = .failure(.loading)
        
        self.currentRequest = categoryRepository.getCategories(budgetId: budgetId, archived: archived, count: count, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.categories = .failure(error)
                }
            }, receiveValue: { (categories) in
                print("Received \(categories.count) categories")
                self.categories = .success(categories)
            })
    }
    
    func getCategory(_ categoryId: String) {
        self.category = .failure(.loading)
        
        self.currentRequest = categoryRepository.getCategory(categoryId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    return
                case .failure(let error):
                    self.category = .failure(error)
                }
            }, receiveValue: { (category) in
                self.category = .success(category)
            })
    }

    let objectWillChange = ObservableObjectPublisher()
    private let categoryRepository: CategoryRepository
    init(_ categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
}
