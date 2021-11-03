//
//  TransactionListView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct TransactionListView: View {
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    @State var requestId: String = ""
    @State var isAddingTransaction = false
    
    @ViewBuilder
    var body: some View {
        switch transactionDataStore.transactions[requestId] {
        case .success(let transactions):
            Section {
                List(transactions) { transaction in
                    TransactionListItemView(transaction)
                }
            }
            .sheet(isPresented: $isAddingTransaction, content: {
                AddTransactionView(showSheet: $isAddingTransaction, budgetId: self.budget.id)
                    .navigationBarTitle("add_transaction")
            })
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        self.isAddingTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
            )
        case nil, .failure(.loading):
            VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }.onAppear {
                if transactionDataStore.transactions[requestId] == nil || self.requestId == "" {
                    self.requestId = transactionDataStore.getTransactions(self.budget.id, categoryId: self.category?.id)
                }
            }
        default:
            // TODO: Handle each network failure type
            Text("budgets_load_failure")
            Button("action_retry", action: {
                self.requestId = transactionDataStore.getTransactions(self.budget.id, categoryId: self.category?.id)
            })
        }
    }
    
    let budget: Budget
    let category: Category?
    init(_ budget: Budget, category: Category? = nil) {
        self.budget = budget
        self.category = category
    }
}

struct TransactionListItemView: View {
    var transaction: Transaction
    
    var body: some View {
        NavigationLink(
            destination: TransactionDetailsView(transaction)
                .navigationBarTitle("details", displayMode: .inline)
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: transaction.title)
                        .lineLimit(1)
                        .font(.headline)
                    Text(verbatim: transaction.date.toLocaleString())
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(verbatim: transaction.amount.toCurrencyString())
                        .foregroundColor(transaction.expense ? .red : .green)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.leading)
            }.padding(5.0)
        }
    }
    
    init (_ transaction: Transaction) {
        self.transaction = transaction
    }
}
