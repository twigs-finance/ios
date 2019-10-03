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
            return AnyView(List(transactions) { transaction in
                TransactionListItemView(self.dataStoreProvider, transaction: transaction)
            })
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
        self.transactionDataStore = dataStoreProvider.transactionDataStore(category)
    }
}

struct TransactionListItemView: View {
    var transaction: Transaction
    let dataStoreProvider: DataStoreProvider
    let numberFormatter: NumberFormatter
    
    var body: some View {
        NavigationLink(
            destination: TransactionDetailsView(self.dataStoreProvider, transaction: transaction)
                .navigationBarTitle(transaction.title)
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: transaction.title)
                        .lineLimit(1)
                        .font(.system(size: 20))
                    Text(verbatim: transaction.date.toLocaleString())
                        .lineLimit(1)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(verbatim: self.numberFormatter.string(from: NSNumber(value: Double(transaction.amount) / 100.0)) ?? "")
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
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        self.numberFormatter = formatter
    }
}
