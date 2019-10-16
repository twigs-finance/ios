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
    @State var title: String = ""
    @State var description: String = ""
    @State var date: Date = Date()
    @State var amount: String = ""
    @State var type: TransactionType = .expense
    @State var budgetId: Int? = nil
    @State var categoryId: Int? = nil
    let createdBy: Int
    
    var stateContent: AnyView {
        switch transactionDataStore.transaction {
        case .success(_):
            self.presentationMode.wrappedValue.dismiss()
            return AnyView(EmptyView())
        case .failure(.loading):
            return AnyView(EmbeddedLoadingView())
        default:
                return AnyView(EditTransactionView(
                    title: self.$title,
                    description: self.$description,
                    date: self.$date,
                    amount: self.$amount,
                    type: self.$type,
                    budgetId: self.$budgetId,
                    categoryId: self.$categoryId,
                    dataStoreProvider: self.dataStoreProvider
                ))
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarItems(
                    leading: Button("cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("save") {
                        let amount = Double(self.amount) ?? 0.0
                        self.transactionDataStore.saveTransaction(Transaction(
                            id: nil,
                            title: self.title,
                            description: self.description,
                            date: self.date,
                            amount: Int(amount * 100.0),
                            categoryId: self.categoryId,
                            expense: self.type == TransactionType.expense,
                            createdBy: self.createdBy,
                            budgetId: self.budgetId!
                        ))
                })
        }
    }
    
    @ObservedObject var transactionDataStore: TransactionDataStore
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider) {
        self.dataStoreProvider = dataStoreProvider
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        self.createdBy = try! dataStoreProvider.authenticationDataStore().currentUser.get().id!
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
