//
//  EditTransactionView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/14/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct EditTransactionForm: View {
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
            TextField("prompt_name", text: self.$title)
            TextField("prompt_description", text: self.$description)
            DatePicker(selection: self.$date, label: { Text("prompt_date") })
            TextField("prompt_amount", text: self.$amount)
                .keyboardType(.decimalPad)
            Picker("prompt_type", selection: self.$type) {
                ForEach(TransactionType.allCases) { type in
                    Text(type.localizedKey)
                }
            }
            BudgetPicker(self.$budgetId)
            CategoryPicker(self.$budgetId, categoryId: self.$categoryId, expense: self.$type)
            if deleteAction != nil {
                Button(action: {
                    self.showingAlert = true
                }) {
                    Text("delete")
                        .foregroundColor(.red)
                }
                .alert(isPresented:$showingAlert) {
                    Alert(title: Text("confirm_delete"), message: Text("cannot_undo"), primaryButton: .destructive(Text("delete"), action: deleteAction), secondaryButton: .cancel())
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
        switch self.budgetsDataStore.budgets {
        case .success(let budgets):
            Picker("prompt_budget", selection: self.budgetId) {
                ForEach(budgets) { budget in
                    Text(budget.name)
                }
            }
        default:
            Picker("prompt_budget", selection: self.budgetId) {
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
    @State var requestId: String = ""
    
    @ViewBuilder
    var body: some View {
        switch self.categoryDataStore.categories[requestId] {
        case .success(let categories):
            Picker("prompt_category", selection: self.categoryId) {
                ForEach(categories) { category in
                    Text(category.title)
                }
            }.onAppear {
                if !self.requestId.contains(budgetId.wrappedValue) || !self.requestId.contains(String(describing: self.expense.wrappedValue)) {
                    self.requestId = categoryDataStore.getCategories(budgetId: self.budgetId.wrappedValue, expense: self.expense.wrappedValue == TransactionType.expense, count: nil, page: nil)
                }
            }
        case .failure(.loading):
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }.onAppear {
                if budgetId.wrappedValue != "" {
                    if !self.requestId.contains(budgetId.wrappedValue) {
                        self.requestId = categoryDataStore.getCategories(budgetId: self.budgetId.wrappedValue, expense: self.expense.wrappedValue == TransactionType.expense, count: nil, page: nil)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
    
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    init(_ budgetId: Binding<String>, categoryId: Binding<String>, expense: Binding<TransactionType>) {
        self.budgetId = budgetId
        self.categoryId = categoryId
        self.expense = expense
    }
}

//
//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView()
//    }
//}
