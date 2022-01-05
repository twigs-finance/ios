//
//  CategoryForm.swift
//  Twigs
//
//  Created by William Brawner on 1/4/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import Foundation
import TwigsCore

class CategoryForm: ObservableObject {
    let category: TwigsCore.Category?
    let categoryList: CategoryListDataStore
    let budgetId: String
    let categoryId: String
    @Published var title: String
    @Published var description: String
    @Published var amount: String
    @Published var type: TransactionType
    @Published var archived: Bool
    let showDelete: Bool
    
    init(
        category: TwigsCore.Category?,
        categoryList: CategoryListDataStore,
        budgetId: String
    ) {
        self.category = category
        self.categoryList = categoryList
        self.budgetId = budgetId
        self.categoryId = category?.id ?? ""
        self.showDelete = !self.categoryId.isEmpty
        let baseCategory = category ?? TwigsCore.Category(budgetId: budgetId)
        self.title = baseCategory.title
        self.description = baseCategory.description ?? ""
        self.amount = baseCategory.amountString
        self.archived = baseCategory.archived
        self.type = baseCategory.type
    }
    

    func save() async {
        let amount = Int((Double(self.amount) ?? 0.0) * 100)
        await categoryList.save(TwigsCore.Category(
            budgetId: budgetId,
            id: categoryId,
            title: title,
            description: description,
            amount: amount,
            expense: type.toBool(),
            archived: archived
        ))
    }
    
    func delete() async {
        guard let category = self.category else {
            return
        }
        await categoryList.delete(category)
    }
}
