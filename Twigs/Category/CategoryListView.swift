//
//  CategoriesView.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct CategoryListView: View {
    @ObservedObject var categoryDataStore: CategoryDataStore

    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch self.categoryDataStore.categories {
        case .success(let categories):
            return AnyView(
                Section {
                    List(categories) { category in
                        CategoryListItemView(self.dataStoreProvider, budget: budget, category: category)
                    }
                }
            )
        case .failure(.loading):
            return AnyView(VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            })
        default:
            // TODO: Handle each network failure type
            return AnyView(Text("budgets_load_failure"))
        }
    }
    
    private let dataStoreProvider: DataStoreProvider
    private let budget: Budget
    init(_ dataStoreProvider: DataStoreProvider, budget: Budget) {
        self.dataStoreProvider = dataStoreProvider
        let categoryDataStore = dataStoreProvider.categoryDataStore()
        self.budget = budget
        categoryDataStore.getCategories(budgetId: budget.id)
        self.categoryDataStore = categoryDataStore
    }
}

struct CategoryListItemView: View {
    var category: Category
    let budget: Budget
    let dataStoreProvider: DataStoreProvider
    let sumId: String
    @ObservedObject var transactionDataStore: TransactionDataStore
    
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
            destination: TransactionListView(self.dataStoreProvider, budget: self.budget, category: category)
                .navigationBarTitle(category.title)
        ) {
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
            }
        }
    }
    
    var progressView: ProgressView {
        var balance: Float = 0.0
        if case .success(let sum) = transactionDataStore.sums[sumId] {
            balance = Float(abs(sum.balance))
        }
        return ProgressView(value: balance, maxValue: Float(category.amount), progressTintColor: progressTintColor, progressBarHeight: 4.0)
    }
    
    var remaining: Text {
        var remaining = ""
        var color = Color.primary
        if case .success(let sum) = transactionDataStore.sums[sumId] {
            let amount = category.amount - abs(sum.balance)
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
    
    init (_ dataStoreProvider: DataStoreProvider, budget: Budget, category: Category) {
        self.dataStoreProvider = dataStoreProvider
        self.budget = budget
        self.category = category
        let transactionDataStore = dataStoreProvider.transactionDataStore()
        self.transactionDataStore = transactionDataStore
        self.sumId = transactionDataStore.sum(categoryId: category.id)
    }
}


//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
