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
    @Published var categories: [String:Result<[Category], NetworkError>] = ["":.failure(.loading)]
    
    var category: Result<Category, NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    func getCategories(budgetId: String? = nil, expense: Bool? = nil, archived: Bool? = false, count: Int? = nil, page: Int? = nil) -> String {
        let requestId = "\(budgetId ?? "all")-\(String(describing: expense))"
        self.categories[requestId] = .failure(.loading)
        
        self.currentRequest = categoryRepository.getCategories(budgetId: budgetId, expense: expense, archived: archived, count: count, page: page)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    self.currentRequest = nil
                    self.objectWillChange.send() // TODO: Remove hack after finding better way to update dictionary values
                    return
                case .failure(let error):
                    self.categories[requestId] = .failure(error)
                }
            }, receiveValue: { (categories) in
                print("Received \(categories.count) categories")
                self.categories[requestId] = .success(categories)
            })
        
        return requestId
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
