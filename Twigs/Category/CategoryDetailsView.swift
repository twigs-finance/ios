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
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    let budget: Budget
    let category: TwigsCore.Category
    @State var sum: Int? = 0
    @State var editingCategory: Bool = false
    var spent: Int {
        get {
            if let sum = self.sum {
                return abs(sum)
            } else {
                return 0
            }
        }
    }
    var remaining: Int {
        get {
            return category.amount - spent
        }
    }
    var middleLabel: LocalizedStringKey {
        get {
            if category.expense {
                return LocalizedStringKey("amount_spent")
            } else {
                return LocalizedStringKey("amount_earned")
            }
        }
    }
    
    var body: some View {
        TransactionListView(self.budget, category: category) {
            VStack {
                Text(verbatim: category.description ?? "")
                    .padding()
                HStack {
                    LabeledCounter(title: LocalizedStringKey("amount_budgeted"), amount: category.amount)
                    LabeledCounter(title: middleLabel, amount: spent)
                    LabeledCounter(title: LocalizedStringKey("amount_remaining"), amount: remaining)
                }
            }.frame(maxWidth: .infinity, alignment: .center)
        }

        .onAppear {
            Task {
                try await self.sum = transactionDataStore.sum(budgetId: nil, categoryId: category.id, from: nil, to: nil)
            }
        }
        .navigationBarItems(trailing: Button(action: {
                self.editingCategory = true
            }) {
                Text("edit")
            }
        )
        .sheet(isPresented: self.$editingCategory, onDismiss: {
            self.editingCategory = false
        }, content: {
            CategoryFormSheet(showSheet: self.$editingCategory, category: self.category, budgetId: self.category.budgetId)
        })
    }
    
    init (_ category: TwigsCore.Category, budget: Budget) {
        self.category = category
        self.budget = budget
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
        CategoryDetailsView(MockCategoryRepository.category, budget: MockBudgetRepository.budget)
            .environmentObject(TransactionDataStore(MockTransactionRepository()))
    }
}
#endif
