//
//  RecurringTransactionView.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

struct RecurringTransactionsListView: View {
    @ObservedObject var dataStore: RecurringTransactionDataStore
    
    var body: some View {
        switch dataStore.transactions {
        case .success(let transactions):
            List {
                ForEach(transactions) { transaction in
                    RecurringTransactionsListItemView(transaction)
                }
            }
        default:
            ActivityIndicator(isAnimating: .constant(true), style: .medium)
        }
    }
}

#if DEBUG
struct RecurringTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsListView(dataStore: RecurringTransactionDataStore(MockRecurringTransactionRepository(), budgetId: ""))
    }
}
#endif

struct RecurringTransactionsListItemView: View {
    let transaction: RecurringTransaction
    
    init (_ transaction: RecurringTransaction) {
        self.transaction = transaction
    }

    var body: some View {
        NavigationLink(
            destination: RecurringTransactionDetailsView(transaction)
                .navigationBarTitle("details", displayMode: .inline)
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: transaction.title)
                        .lineLimit(1)
                        .font(.headline)
                    if let description = transaction.description?.trimmingCharacters(in: CharacterSet([" "])), !description.isEmpty {
                        Text(verbatim: description)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
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
}

#if DEBUG
struct RecurringTransactionsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsListItemView(MockRecurringTransactionRepository.transaction)
    }
}
#endif
