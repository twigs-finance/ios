//
//  TransactionEditView.swift
//  BudgetApp
//
//  Created by Billy Brawner on 10/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TransactionEditView: View {
    @Environment(\.presentationMode) var presentationMode
    var title: State<String>
    var description: State<String>
    var date: State<Date>
    var amount: State<String>
    var type: State<TransactionType>
    var budgetId: State<Int?>
    var categoryId: State<Int?>
    let createdBy: Int
    let id: Int?
    var shouldNavigateUp: Binding<Bool>
    
    var stateContent: AnyView {
        switch transactionDataStore.transaction {
        case .success(_), .failure(.deleted):
            self.shouldNavigateUp.wrappedValue = true
            self.presentationMode.wrappedValue.dismiss()
            return AnyView(EmptyView())
        case .failure(.loading):
            return AnyView(EmbeddedLoadingView())
        default:
            return AnyView(EditTransactionForm(
                title: self.title.projectedValue,
                description: self.description.projectedValue,
                date: self.date.projectedValue,
                amount: self.amount.projectedValue,
                type: self.type.projectedValue,
                budgetId: self.budgetId.projectedValue,
                categoryId: self.categoryId.projectedValue,
                dataStoreProvider: self.dataStoreProvider,
                deleteAction: {
                    self.transactionDataStore.deleteTransaction(self.id!)
            }
            ))
        }
    }
    
    var body: some View {
        stateContent
            .navigationBarItems(trailing: Button("save") {
                let amount = Double(self.amount.wrappedValue) ?? 0.0
                self.transactionDataStore.saveTransaction(Transaction(
                    id: self.id,
                    title: self.title.wrappedValue,
                    description: self.description.wrappedValue,
                    date: self.date.wrappedValue,
                    amount: Int(amount * 100.0),
                    categoryId: self.categoryId.wrappedValue,
                    expense: self.type.wrappedValue == TransactionType.expense,
                    createdBy: self.createdBy,
                    budgetId: self.budgetId.wrappedValue!
                ))
            })
    }
    
    @ObservedObject var transactionDataStore: TransactionDataStore
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider, transaction: Transaction, shouldNavigateUp: Binding<Bool>) {
        self.dataStoreProvider = dataStoreProvider
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        self.createdBy = try! dataStoreProvider.authenticationDataStore().currentUser.get().id!
        self.id = transaction.id
        self.title = State<String>(initialValue: transaction.title)
        self.description = State<String>(initialValue: transaction.description ?? "")
        self.date = State<Date>(initialValue: transaction.date)
        self.amount = State<String>(initialValue: transaction.amountString)
        self.type = State<TransactionType>(initialValue: transaction.type)
        self.budgetId = State<Int?>(initialValue: transaction.budgetId)
        self.categoryId = State<Int?>(initialValue: transaction.categoryId)
        self.shouldNavigateUp = shouldNavigateUp
    }
}

#if DEBUG
struct TransactionEditView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionEditView(MockDataStoreProvider(), transaction: MockTransactionRepository.transaction, shouldNavigateUp: .constant(false))
    }
}
#endif
