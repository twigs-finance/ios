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
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService) {
        self.apiService = apiService
    }
    
    func sum(categoryId: String, from: Date? = nil, to: Date? = nil) async {
        self.sum = .loading
        do {
            let sum = try await self.apiService.sumTransactions(budgetId: nil, categoryId: categoryId, from: from, to: to).balance
            self.sum = .success(sum)
        } catch {
            self.sum = .error(error)
        }
    }
}
