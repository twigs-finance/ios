//
//  AddTransactionView.swift
//  Budget
//
//  Created by Billy Brawner on 10/10/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine
import TwigsCore

struct AddTransactionView: View {
    @Binding var showSheet: Bool
    @EnvironmentObject var authDataStore: AuthenticationDataStore
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    @State var loading: Bool = false
    @State var title: String = ""
    @State var description: String = ""
    @State var date: Date = Date()
    @State var amount: String = ""
    @State var type: TransactionType = .expense
    @State var budgetId: String = ""
    @State var categoryId: String = ""
    var createdBy: String {
        get {
            return authDataStore.currentUser!.id
        }
    }
    
    @ViewBuilder
    var stateContent: some View {
        if let _ = transactionDataStore.transaction {
            EmptyView().onAppear {
                self.showSheet = false
            }
        } else if loading {
            EmbeddedLoadingView()
        } else {
            EditTransactionForm(
                title: self.$title,
                description: self.$description,
                date: self.$date,
                amount: self.$amount,
                type: self.$type,
                budgetId: self.$budgetId,
                categoryId: self.$categoryId,
                deleteAction: nil
            )
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarItems(
                    leading: Button("cancel") {
                        self.showSheet = false
                    },
                    trailing: Button("save") {
                        let amount = Double(self.amount) ?? 0.0
                        Task {
                            try await self.transactionDataStore.saveTransaction(TwigsCore.Transaction(
                                id: "",
                                title: self.title,
                                description: self.description,
                                date: self.date,
                                amount: Int(amount * 100.0),
                                categoryId: self.categoryId != "" ? self.categoryId : nil,
                                expense: self.type == TransactionType.expense,
                                createdBy: self.createdBy,
                                budgetId: self.budgetId
                            ))
                        }
                })
        }
        .onDisappear {
            Task {
                try await self.transactionDataStore.getTransactions(self.budgetId, categoryId: self.categoryId)
            }
            self.transactionDataStore.clearSelectedTransaction()
            self.title = ""
            self.description = ""
            self.date = Date()
            self.amount = ""
            self.type = .expense
            self.categoryId = ""
        }
    }
    
    init(showSheet: Binding<Bool>, budgetId: String, categoryId: String = "") {
        self._showSheet = showSheet
        self._budgetId = State(initialValue: budgetId)
        self._categoryId = State(initialValue: categoryId)
    }
}

//struct AddTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTransactionView()
//    }
//}
