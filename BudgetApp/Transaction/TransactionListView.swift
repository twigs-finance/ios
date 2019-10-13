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
    @ObservedObject var transactionDataStore: TransactionDataStore
    
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch transactionDataStore.transactions {
        case .success(let transactions):
            return AnyView(
                Section{
                    List(transactions) { transaction in
                        TransactionListItemView(self.dataStoreProvider, transaction: transaction)
                    }
                }
            )
        case .failure(.loading):
            return AnyView(VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            })
        default:
            // TODO: Handle each network failure type
            return AnyView(Text("budgets_load_failure"))
        }
    }
    
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider, category: Category? = nil) {
        self.dataStoreProvider = dataStoreProvider
        self.transactionDataStore = dataStoreProvider.transactionDataStore()
        self.transactionDataStore.getTransactions(category)
    }
}

struct TransactionListItemView: View {
    var transaction: Transaction
    let dataStoreProvider: DataStoreProvider
    
    var body: some View {
        NavigationLink(
            destination: TransactionDetailsView(self.dataStoreProvider, transactionId: transaction.id!)
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
                    Text(verbatim: transaction.amount.toCurrencyString() ?? "")
                        .foregroundColor(transaction.expense ? .red : .green)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.leading)
            }.padding(5.0)
        }
    }
    
    init (_ dataStoreProvider: DataStoreProvider, transaction: Transaction) {
        self.dataStoreProvider = dataStoreProvider
        self.transaction = transaction
    }
}
