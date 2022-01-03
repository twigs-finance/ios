//
//  EditTransactionView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/14/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct EditTransactionForm: View {
    @EnvironmentObject var authDataStore: AuthenticationDataStore
    @Binding var title: String
    @Binding var description: String
    @Binding var date: Date
    @Binding var amount: String
    @Binding var type: TransactionType
    @Binding var budgetId: String
    @Binding var categoryId: String
    @State private var showingAlert = false
    let deleteAction: (() -> ())?
    
    var body: some View {
        Form {
            TextField(LocalizedStringKey("prompt_name"), text: self.$title)
                .textInputAutocapitalization(.words)
            TextField(LocalizedStringKey("prompt_description"), text: self.$description)
                .textInputAutocapitalization(.sentences)
            DatePicker(selection: self.$date, label: { Text(LocalizedStringKey("prompt_date")) })
            TextField(LocalizedStringKey("prompt_amount"), text: self.$amount)
                .keyboardType(.decimalPad)
            Picker(LocalizedStringKey("prompt_type"), selection: self.$type) {
                ForEach(TransactionType.allCases) { type in
                    Text(type.localizedKey)
                }
            }
            BudgetPicker(self.$budgetId)
            CategoryPicker(self.$budgetId, categoryId: self.$categoryId, expense: self.$type, apiService: self.authDataStore.apiService)
            if deleteAction != nil {
                Button(action: {
                    self.showingAlert = true
                }) {
                    Text(LocalizedStringKey("delete"))
                        .foregroundColor(.red)
                }
                .alert(isPresented:$showingAlert) {
                    Alert(title: Text(LocalizedStringKey("confirm_delete")), message: Text(LocalizedStringKey("cannot_undo")), primaryButton: .destructive(Text(LocalizedStringKey("delete")), action: deleteAction), secondaryButton: .cancel())
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct BudgetPicker: View {
    var budgetId: Binding<String>
    
    @ViewBuilder
    var body: some View {
        if let budgets = self.budgetsDataStore.budgets {
            Picker(LocalizedStringKey("prompt_budget"), selection: self.budgetId) {
                ForEach(budgets) { budget in
                    Text(budget.name)
                }
            }
        } else {
            Picker(LocalizedStringKey("prompt_budget"), selection: self.budgetId) {
                Text("")
            }
        }
    }
    
    @EnvironmentObject var budgetsDataStore: BudgetsDataStore
    init(_ budgetId: Binding<String>) {
        self.budgetId = budgetId
    }
}

struct CategoryPicker: View {
    let budgetId: Binding<String>
    var categoryId: Binding<String>
    let expense: Binding<TransactionType>
    
    @ViewBuilder
    var body: some View {
        if let categories = self.categoryDataStore.categories {
            Picker(LocalizedStringKey("prompt_category"), selection: self.categoryId) {
                ForEach(categories) { category in
                    Text(category.title)
                }
            }
        } else {
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            }.onAppear {
                Task {
                    try await self.categoryDataStore.getCategories(budgetId: self.budgetId.wrappedValue, expense: self.expense.wrappedValue == TransactionType.expense, archived: false)
                }
            }
        }
    }
    
    @StateObject var categoryDataStore: CategoryListDataStore
    init(_ budgetId: Binding<String>, categoryId: Binding<String>, expense: Binding<TransactionType>, apiService: TwigsApiService) {
        self.budgetId = budgetId
        self.categoryId = categoryId
        self.expense = expense
        self._categoryDataStore = StateObject(wrappedValue: CategoryListDataStore(apiService))
    }
}

//
//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView()
//    }
//}
