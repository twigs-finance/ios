//
//  EditTransactionView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/14/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct TransactionFormSheet: View {
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    @ObservedObject var transactionForm: TransactionForm
    @State private var showingAlert = false
    
    @ViewBuilder
    var body: some View {
        switch self.transactionDataStore.transaction {
        case .loading:
            EmbeddedLoadingView()
        default:
            Form {
                TextField(LocalizedStringKey("prompt_name"), text: $transactionForm.title)
                    .textInputAutocapitalization(.words)
                TextField(LocalizedStringKey("prompt_description"), text: $transactionForm.description)
                    .textInputAutocapitalization(.sentences)
                DatePicker(selection: $transactionForm.date, label: { Text(LocalizedStringKey("prompt_date")) })
                TextField(LocalizedStringKey("prompt_amount"), text: $transactionForm.amount)
                    .keyboardType(.decimalPad)
                Picker(LocalizedStringKey("prompt_type"), selection: $transactionForm.type) {
                    ForEach(TransactionType.allCases) { type in
                        Text(type.localizedKey)
                    }
                }
                BudgetPicker()
                CategoryPicker()
                if transactionForm.showDelete {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text(LocalizedStringKey("delete"))
                            .foregroundColor(.red)
                    }
                    .alert(isPresented:$showingAlert) {
                        Alert(
                            title: Text(LocalizedStringKey("confirm_delete")),
                            message: Text(LocalizedStringKey("cannot_undo")),
                            primaryButton: .destructive(
                                Text(LocalizedStringKey("delete")),
                                action: { Task { await transactionForm.delete() }}
                            ),
                            secondaryButton: .cancel()
                        )
                    }
                } else {
                    EmptyView()
                }
            }.environmentObject(transactionForm)
        }
    }
}

struct BudgetPicker: View {
    @EnvironmentObject var transactionForm: TransactionForm

    @ViewBuilder
    var body: some View {
        if case let .success(budgets) = self.transactionForm.budgets {
            Picker(LocalizedStringKey("prompt_budget"), selection: $transactionForm.budgetId) {
                ForEach(budgets) { budget in
                    Text(budget.name)
                }
            }
        } else {
            Picker(LocalizedStringKey("prompt_budget"), selection: $transactionForm.budgetId) {
                Text("")
            }
        }
    }
}

struct CategoryPicker: View {
    @EnvironmentObject var transactionForm: TransactionForm
    
    @ViewBuilder
    var body: some View {
        if case let .success(categories) = self.transactionForm.categories {
            Picker(LocalizedStringKey("prompt_category"), selection: $transactionForm.categoryId) {
                ForEach(categories) { category in
                    Text(category.title)
                }
            }
        } else {
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            }
        }
    }
}

//
//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView()
//    }
//}
