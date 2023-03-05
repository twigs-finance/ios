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
    @EnvironmentObject var dataStore: DataStore
    @State var requestId: String = ""
    private var budgetId: String {
        get {
            if case let .success(budget) = dataStore.budget {
                return budget.id
            } else {
                return ""
            }
        }
    }
    
    @ViewBuilder
    var body: some View {
        List(selection: $dataStore.selectedCategory) {
            InlineLoadingView(
                data: $dataStore.categories,
                action: { await self.dataStore.getCategories(budgetId: budget.id, expense: nil, archived: nil, count: nil, page: nil) },
                errorTextLocalizedStringKey: "Failed to load categories"
            ) { categories in
                if categories.isEmpty {
                    Text("no_categories")
                } else {
                    Section {
                        ForEach(categories.filter { !$0.archived }) { category in
                            CategoryListItemView(CategoryDataStore(dataStore.apiService), budget: budget, category: category)
                        }
                    }
                    if categories.contains(where: { $0.archived }) {
                        Section("Archived") {
                            ForEach(categories.filter { $0.archived }) { category in
                                CategoryListItemView(CategoryDataStore(dataStore.apiService), budget: budget, category: category)
                            }
                        }
                    }
                }
            }
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await dataStore.getCategories()
        }
        #endif
        .navigationBarItems(trailing: Button(action: {
            Task {
                await dataStore.edit(TwigsCore.Category(budgetId: budgetId))
            }
        }, label: {
            Image(systemName: "plus").padding()
        }))
        .sheet(isPresented: self.$dataStore.editingCategory, onDismiss: {
            self.dataStore.cancelEditCategory()
        }, content: {
            CategoryFormSheet(categoryForm: CategoryForm(
                category: TwigsCore.Category(budgetId: budgetId),
                dataStore: dataStore,
                budgetId: budgetId
            ))
        })
    }
    
    private let budget: Budget
    init(_ budget: Budget) {
        self.budget = budget
    }
}

struct CategoryListItemView: View {
    let category: TwigsCore.Category
    let budget: Budget
    @EnvironmentObject var dataStore: DataStore
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
        NavigationLink(value: category, label: {
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
        .environmentObject(categoryDataStore)
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
