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
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var transactionForm: TransactionForm
    @State private var showingAlert = false
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            switch self.dataStore.transaction {
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
                    BudgetPicker(budgets: $transactionForm.budgets, budgetId: $transactionForm.budgetId)
                    CategoryPicker(categories: $transactionForm.categories, categoryId: $transactionForm.categoryId)
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
                    .task {
                        await transactionForm.load()
                    }
                    .navigationTitle(transactionForm.transactionId.isEmpty ? "add_transaction" : "edit_transaction")
                    .navigationBarItems(
                        leading: Button("cancel", action: { dataStore.cancelEditTransaction() }),
                        trailing: Button("save", action: {
                            Task {
                                await transactionForm.save()
                            }
                        })
                    )
            }
        }
    }
}

struct BudgetPicker: View {
    @Binding var budgets: AsyncData<[Budget]>
    @Binding var budgetId: String
    
    @ViewBuilder
    var body: some View {
        if case let .success(budgets) = budgets {
            Picker(LocalizedStringKey("prompt_budget"), selection: $budgetId) {
                ForEach(budgets) { budget in
                    Text(budget.name)
                }
            }
        } else {
            Picker(LocalizedStringKey("prompt_budget"), selection: $budgetId) {
                Text("")
            }
        }
    }
}

struct CategoryPicker: View {
    @Binding var categories: AsyncData<[TwigsCore.Category]>
    @Binding var categoryId: String

    @ViewBuilder
    var body: some View {
        if case let .success(categories) = categories {
            Picker(LocalizedStringKey("prompt_category"), selection: $categoryId) {
                ForEach(categories) { category in
                    Text(category.title).tag(category.id)
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
