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
    @State var title: String
    @State var description: String
    @State var date: Date
    @State var amount: String
    @State var type: TransactionType
    @State var budgetId: String
    @State var categoryId: String
    let createdBy: String
    let id: String?
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
                title: self.$title,
                description: self.$description,
                date: self.$date,
                amount: self.$amount,
                type: self.$type,
                budgetId: self.$budgetId,
                categoryId: self.$categoryId,
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
                let amount = Double(self.amount) ?? 0.0
                self.transactionDataStore.saveTransaction(Transaction(
                    id: self.id ?? "",
                    title: self.title,
                    description: self.description,
                    date: self.date,
                    amount: Int(amount * 100.0),
                    categoryId: self.categoryId,
                    expense: self.type == TransactionType.expense,
                    createdBy: self.createdBy,
                    budgetId: self.budgetId
                ))
            })
    }
    
    @ObservedObject var transactionDataStore: TransactionDataStore
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider, transaction: Transaction, shouldNavigateUp: Binding<Bool>) {
        self.dataStoreProvider = dataStoreProvider
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        self.createdBy = try! dataStoreProvider.authenticationDataStore().currentUser.get().id
        self.id = transaction.id
        self._title = State<String>(initialValue: transaction.title)
        self._description = State<String>(initialValue: transaction.description ?? "")
        self._date = State<Date>(initialValue: transaction.date)
        self._amount = State<String>(initialValue: transaction.amountString)
        self._type = State<TransactionType>(initialValue: transaction.type)
        self._budgetId = State<String>(initialValue: transaction.budgetId)
        self._categoryId = State<String>(initialValue: transaction.categoryId ?? "")
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
