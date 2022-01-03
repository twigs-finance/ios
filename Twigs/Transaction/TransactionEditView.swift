//
//  TransactionEditView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/16/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct TransactionEditView: View {
    @State var loading: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var title: String
    @State var description: String
    @State var date: Date
    @State var amount: String
    @State var type: TransactionType
    @State var budgetId: String
    @State var categoryId: String
    var createdBy: String {
        get {
            return authDataStore.currentUser!.id
        }
    }
    let id: String?
    var shouldNavigateUp: Binding<Bool>
    
    @ViewBuilder
    var stateContent: some View {
        if let _ = self.transactionDataStore.transaction {
            EditTransactionForm(
                title: self.$title,
                description: self.$description,
                date: self.$date,
                amount: self.$amount,
                type: self.$type,
                budgetId: self.$budgetId,
                categoryId: self.$categoryId,
                deleteAction: {
                    Task {
                        self.loading = true
                        try await self.transactionDataStore.deleteTransaction(self.id!)
                    }
                })
        } else {
            EmbeddedLoadingView().onAppear {
                self.shouldNavigateUp.wrappedValue = true
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var body: some View {
        stateContent
            .navigationBarItems(trailing: Button("save") {
                let amount = Double(self.amount) ?? 0.0
                Task {
                    try await self.transactionDataStore.saveTransaction(TwigsCore.Transaction(
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
                }
            })
    }
    
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    @EnvironmentObject var authDataStore: AuthenticationDataStore
    init(_ transaction: TwigsCore.Transaction, shouldNavigateUp: Binding<Bool>) {
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
        TransactionEditView(MockTransactionRepository.transaction, shouldNavigateUp: .constant(false))
    }
}
#endif
