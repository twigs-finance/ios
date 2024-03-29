//
//  CategoryDetailsView.swift
//  Twigs
//
//  Created by William Brawner on 10/19/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct CategoryDetailsView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var categoryDataStore: CategoryDataStore
    @EnvironmentObject var apiService: TwigsApiService
    let budget: Budget
    @State var sum: Int? = 0
    var spent: Int {
        get {
            if case let .success(sum) = categoryDataStore.sum {
                return abs(sum)
            } else {
                return 0
            }
        }
    }
    func middleLabel(_ category: TwigsCore.Category) -> LocalizedStringKey {
        if category.expense {
            return LocalizedStringKey("amount_spent")
        } else {
            return LocalizedStringKey("amount_earned")
        }
    }

    var body: some View {
        if let category = dataStore.selectedCategory {
            TransactionListView() {
                VStack {
                    Text(verbatim: category.description ?? "")
                        .padding()
                    HStack {
                        LabeledCounter(title: LocalizedStringKey("amount_budgeted"), amount: category.amount)
                        LabeledCounter(title: middleLabel(category), amount: spent)
                        LabeledCounter(title: LocalizedStringKey("amount_remaining"), amount: category.amount - spent)
                    }
                }.frame(maxWidth: .infinity, alignment: .center)
            }.task {
                await categoryDataStore.sum(categoryId: category.id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        Task {
                            await dataStore.edit(category)
                        }
                    }) {
                        Text("edit")
                    }
                })
            }
            .sheet(isPresented: self.$dataStore.editingCategory, onDismiss: {
                self.dataStore.cancelEditCategory()
            }, content: {
                CategoryFormSheet(categoryForm: CategoryForm(
                    category: category,
                    dataStore: dataStore,
                    budgetId: category.budgetId
                ))
            })
        }
    }

    init (_ budget: Budget, categoryDataStore: CategoryDataStore) {
        self.budget = budget
        self.categoryDataStore = categoryDataStore
    }
}

struct LabeledCounter: View {
    let title: LocalizedStringKey
    let amount: Int
    var body: some View {
        VStack {
            Text(title)
            Text(verbatim: amount.toCurrencyString())
        }
    }
}

#if DEBUG
struct CategoryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryDetailsView(MockBudgetRepository.budget, categoryDataStore: CategoryDataStore(TwigsInMemoryCacheService()))
            .environmentObject(TwigsInMemoryCacheService())
    }
}
#endif
