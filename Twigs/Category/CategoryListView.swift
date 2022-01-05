//
//  CategoriesView.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine
import TwigsCore

struct CategoryListView: View {
    @EnvironmentObject var categoryDataStore: CategoryListDataStore
    @EnvironmentObject var apiService: TwigsApiService
    @State var requestId: String = ""
    
    @ViewBuilder
    var body: some View {
        InlineLoadingView(
            data: $categoryDataStore.categories,
            action: { await self.categoryDataStore.getCategories(budgetId: budget.id, expense: nil, archived: nil, count: nil, page: nil) },
            errorTextLocalizedStringKey: "Failed to load categories"
        ) { categories in
            List {
                Section {
                    ForEach(categories.filter { !$0.archived }) { category in
                        CategoryListItemView(CategoryDataStore(transactionRepository: apiService), budget: budget, category: category)
                    }
                }
                Section("Archived") {
                    ForEach(categories.filter { $0.archived }) { category in
                        CategoryListItemView(CategoryDataStore(transactionRepository: apiService), budget: budget, category: category)
                    }
                }
            }
        }
    }
    
    private let budget: Budget
    init(_ budget: Budget) {
        self.budget = budget
    }
}

struct CategoryListItemView: View {
    let category: TwigsCore.Category
    let budget: Budget
    @EnvironmentObject var categoryListDataStore: CategoryListDataStore
    @ObservedObject var categoryDataStore: CategoryDataStore
    
    init(_ categoryDataStore: CategoryDataStore, budget: Budget, category: TwigsCore.Category) {
        self.categoryDataStore = categoryDataStore
        self.budget = budget
        self.category = category
    }
    
    var progressTintColor: Color {
        get {
            if category.expense {
                return Color.red
            } else {
                return Color.green
            }
        }
    }
    
    var body: some View {
        NavigationLink(
            tag: category,
            selection: $categoryListDataStore.selectedCategory,
            destination: {
                CategoryDetailsView(self.budget)
                    .environmentObject(categoryDataStore)
                    .navigationBarTitle(categoryListDataStore.selectedCategory?.title ?? "")
            },
            label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text(verbatim: category.title)
                        Spacer()
                        remaining
                    }
                    if category.description?.isEmpty == false {
                        Text(verbatim: category.description!)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    progressView
                }.task {
                    await categoryDataStore.sum(categoryId: category.id)
                }
            })
    }
    
    var progressView: ProgressView {
        var balance: Float = 0.0
        if case let .success(sum) = categoryDataStore.sum {
            balance = Float(abs(sum))
        }
        return ProgressView(value: balance, maxValue: Float(category.amount), progressTintColor: progressTintColor, progressBarHeight: 4.0)
    }
    
    var remaining: Text {
        var remaining = ""
        var color = Color.primary
        if case let .success(sum) = categoryDataStore.sum {
            let amount = category.amount - abs(sum)
            if amount < 0 {
                remaining = abs(amount).toCurrencyString() + " over budget"
                if category.expense {
                    color = Color.red
                } else {
                    color = Color.green
                }
            } else {
                remaining = amount.toCurrencyString() + " remaining"
            }
        }
        return Text(verbatim: remaining).foregroundColor(color)
    }
}


//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
