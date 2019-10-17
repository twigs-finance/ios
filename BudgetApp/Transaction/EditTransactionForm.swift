//
//  EditTransactionView.swift
//  BudgetApp
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
    @Binding var budgetId: Int?
    @Binding var categoryId: Int?
    @State private var showingAlert = false
    let dataStoreProvider: DataStoreProvider
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
            BudgetPicker(self.dataStoreProvider, budgetId: self.$budgetId)
            CategoryPicker(self.dataStoreProvider, budgetId: self.$budgetId, categoryId: self.$categoryId)
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
    var budgetId: Binding<Int?>
    var stateContent: AnyView {
        switch self.budgetsDataStore.budgets {
        case .success(let budgets):
            return AnyView(
                Picker("prompt_budget", selection: self.budgetId) {
                    ForEach(budgets) { budget in
                        Text(budget.name)
                    }
                }
            )
        default:
            return AnyView(
                Picker("prompt_budget", selection: self.budgetId) {
                    Text("")
                }
            )
        }
    }
    
    var body: some View {
        stateContent
    }
    
    @ObservedObject var budgetsDataStore: BudgetsDataStore
    init(_ dataStoreProvider: DataStoreProvider, budgetId: Binding<Int?>) {
        let budgetsDataStore = dataStoreProvider.budgetsDataStore()
        budgetsDataStore.getBudgets()
        self.budgetsDataStore = budgetsDataStore
        self.budgetId = budgetId
    }
}

struct CategoryPicker: View {
    var categoryId: Binding<Int?>
    var stateContent: AnyView {
        switch self.categoryDataStore.categories {
        case .success(let categories):
            return AnyView(
                Picker("prompt_category", selection: self.categoryId) {
                    ForEach(categories) { category in
                        Text(category.title)
                    }
                }
            )
        default:
            return AnyView(
                Picker("prompt_category", selection: self.categoryId) {
                    Text("")
                }
            )
        }
    }
    
    var body: some View {
        stateContent
    }
    
    @ObservedObject var categoryDataStore: CategoryDataStore
    init(_ dataStoreProvider: DataStoreProvider, budgetId: Binding<Int?>, categoryId: Binding<Int?>) {
        let categoryDataStore = dataStoreProvider.categoryDataStore()
        categoryDataStore.getCategories(budgetId: budgetId.wrappedValue, count: nil, page: nil)
        self.categoryDataStore = categoryDataStore
        self.categoryId = categoryId
    }
}

//
//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTransactionView()
//    }
//}
