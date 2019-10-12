//
//  AddTransactionView.swift
//  Budget
//
//  Created by Billy Brawner on 10/10/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var id: Int? = nil
    @State var title: String = ""
    @State var description: String = ""
    @State var date: Date = Date()
    @State var amount: String = ""
    @State var type: TransactionType = .expense
    @State var categoryId: Int? = nil
    @ObservedObject var budgetPublisher = Observable<Int?>(nil)
    let createdBy: Int
    
    var stateContent: AnyView {
        switch transactionDataStore.transaction {
        case .success(_):
            // TODO: Figure out how to pass transaction up to previous view
            self.presentationMode.wrappedValue.dismiss()
            return AnyView(EmptyView())
            
        case .failure(.loading):
            return AnyView(VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            })
        default:
            // TODO: Handle each network failure type
            return AnyView(Form {
                Section {
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
                    budgetPicker
                    categoryPicker
                }
            })
        }
    }
    
    var budgetPicker: some View {
        switch budgetsDataStore.budgets {
        case .success(let budgets):
            return AnyView(
                Picker(selection: $budgetPublisher.value, label: Text("prompt_budget")) {
                    ForEach(budgets) { budget in
                        Text(budget.name)
                    }
                }.onReceive(budgetPublisher.publisher, perform: { budget in
                    self.categoryDataStore.getCategories(budgetId: budget!)
                })
            )
        default:
            return AnyView(VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            })
        }
    }
    
    var categoryPicker: some View {
        switch categoryDataStore.categories {
        case .success(let categories):
            return AnyView(
                Picker("prompt_category", selection: self.$categoryId) {
                    ForEach(categories) { category in
                        Text(category.title)
                    }
                }
            )
        default:
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarTitle("add_transaction")
                .navigationBarItems(
                    leading: Button("cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("save") {
                        let amount = Double(self.amount) ?? 0.0
                        
                        self.transactionDataStore.createTransaction(Transaction(
                            id: self.id,
                            title: self.title,
                            description: self.description,
                            date: self.date,
                            amount: Int(amount * 100.0),
                            categoryId: self.categoryId!,
                            expense: self.type == TransactionType.expense,
                            createdBy: self.createdBy,
                            budgetId: self.budgetPublisher.value!
                        ))
                })
        }
    }
    
    @ObservedObject var transactionDataStore: TransactionDataStore
    @ObservedObject var budgetsDataStore: BudgetsDataStore
    @ObservedObject var categoryDataStore: CategoryDataStore
    init(_ dataStoreProvider: DataStoreProvider) {
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        let budgetsDataStore = dataStoreProvider.budgetsDataStore()
        budgetsDataStore.getBudgets()
        self.budgetsDataStore = budgetsDataStore
        let categoryDataStore = dataStoreProvider.categoryDataStore()
        self.categoryDataStore = categoryDataStore
        self.createdBy = try! dataStoreProvider.userDataStore().currentUser.get().id!
    }
}


//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
