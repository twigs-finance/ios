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
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    @State var requestId: String = ""

    @ViewBuilder
    var body: some View {
        switch self.categoryDataStore.categories[requestId] {
        case .success(let categories):
                Section {
                    List(categories) { category in
                        CategoryListItemView(budget, category: category)
                    }
                }
        case .failure(.loading):
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }.onAppear {
                if self.requestId == "" {
                    self.requestId = categoryDataStore.getCategories(budgetId: budget.id)
                }
            }
        default:
            // TODO: Handle each network failure type
            Text("budgets_load_failure")
        }
    }
    
    private let budget: Budget
    init(_ budget: Budget) {
        self.budget = budget
    }
}

struct CategoryListItemView: View {
    var category: Category
    let budget: Budget
    @State var sumId: String = ""
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    
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
            destination: TransactionListView(self.budget, category: category)
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
        }.onAppear {
            if self.sumId == "" {
                self.sumId = transactionDataStore.sum(categoryId: category.id)
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
    
    init (_ budget: Budget, category: Category) {
        self.budget = budget
        self.category = category
    }
}


//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
