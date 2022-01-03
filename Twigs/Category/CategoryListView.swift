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
    @State var requestId: String = ""

    @ViewBuilder
    var body: some View {
        InlineLoadingView(
            action: { try await self.categoryDataStore.getCategories(budgetId: budget.id, expense: nil, archived: nil, count: nil, page: nil) },
            errorTextLocalizedStringKey: "Failed to load categories"
        ) {
            if let categories = self.categoryDataStore.categories {
                List {
                    Section {
                        ForEach(categories.filter { !$0.archived }) { category in
                            CategoryListItemView(budget, category: category)
                        }
                    }
                    Section("Archived") {
                        ForEach(categories.filter { $0.archived }) { category in
                            CategoryListItemView(budget, category: category)
                        }
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
    @State var sum: Int? = nil
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
            destination: CategoryDetailsView(category, budget: self.budget)
                .navigationBarTitle(category.title)
        ) {
            InlineLoadingView(action: {
                self.sum = try await transactionDataStore.sum(categoryId: category.id)
            }, errorTextLocalizedStringKey: "Failed to load category balance") {
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
        }.onAppear {
            Task {
                self.sum = try await transactionDataStore.sum(categoryId: category.id)
            }
        }
    }
    
    var progressView: ProgressView {
        var balance: Float = 0.0
        if let sum = self.sum {
            balance = Float(abs(sum))
        }
        return ProgressView(value: balance, maxValue: Float(category.amount), progressTintColor: progressTintColor, progressBarHeight: 4.0)
    }
    
    var remaining: Text {
        var remaining = ""
        var color = Color.primary
        if let sum = self.sum {
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
    
    init (_ budget: Budget, category: TwigsCore.Category) {
        self.budget = budget
        self.category = category
    }
}


//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
