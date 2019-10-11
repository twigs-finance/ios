//
//  AddTransactionView.swift
//  Budget
//
//  Created by Billy Brawner on 10/10/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var id: Int? = nil
    @State var title: String = ""
    @State var description: String = ""
    @State var date: Date = Date()
    @State var amount: String = ""
    @State var categoryId: Int = 0
    @State var type: TransactionType = .expense
    @State var budgetId: Int = 0
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
                    // TODO: Figure out how to load budgets dynamically
                    Picker("prompt_budget", selection: self.$type) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.localizedKey)
                        }
                    }
                    // TODO: Figure out how to load categories dynamically
                    Picker("prompt_category", selection: self.$type) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.localizedKey)
                        }
                    }
                }
            })
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarTitle("add_transaction")
                .navigationBarItems(leading: Button("cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                    }, trailing: Button("save") {
                        self.transactionDataStore.createTransaction(Transaction(
                            id: self.id,
                            title: self.title,
                            description: self.description,
                            date: self.date,
                            amount: Int(Double(self.amount) ?? 0.0 * 100.0),
                            categoryId: self.categoryId,
                            expense: self.type == TransactionType.expense,
                            createdBy: self.createdBy,
                            budgetId: self.budgetId
                        ))
                })
        }
    }
    
    @ObservedObject var transactionDataStore: TransactionDataStore
    init(_ dataStoreProvider: DataStoreProvider) {
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        self.createdBy = try! dataStoreProvider.userDataStore().currentUser.get().id!
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
