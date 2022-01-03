//
//  RecurringTransactionView.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct RecurringTransactionsListView: View {
    @ObservedObject var dataStore: RecurringTransactionDataStore
    let budget: Budget
    
    var body: some View {
        InlineLoadingView(
            action: {
                return try await self.dataStore.getRecurringTransactions(self.budget.id)
        },
            errorTextLocalizedStringKey: "Failed to load recurring transactions"
        ) { (transactions: [RecurringTransaction]) in
            List {
                ForEach(transactions) { transaction in
                    RecurringTransactionsListItemView(transaction)
                }
            }
        }
    }
}

#if DEBUG
struct RecurringTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsListView(dataStore: RecurringTransactionDataStore(MockRecurringTransactionRepository()), budget: MockBudgetRepository.budget)
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
