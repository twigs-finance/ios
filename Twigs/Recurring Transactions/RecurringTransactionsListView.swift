//
//  RecurringTransactionView.swift
//  Twigs
//
//  Created by William Brawner on 12/6/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore
import OrderedCollections

struct RecurringTransactionsListView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        InlineLoadingView(
            data: $dataStore.recurringTransactions,
            action: { await self.dataStore.getRecurringTransactions() },
            errorTextLocalizedStringKey: "Failed to load recurring transactions"
        ) { (transactions: OrderedDictionary<String, [RecurringTransaction]>) in
            List(selection: $dataStore.selectedRecurringTransaction) {
                ForEach(transactions.keys, id: \.self) { (key: String) in
                    Group {
                        if !transactions[key]!.isEmpty {
                            Section(header: Text(key)) {
                                ForEach(transactions[key]!) { transaction in
                                    RecurringTransactionsListItemView(transaction)
                                }
                            }
                        }
                    }
                }
            }
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                await dataStore.getRecurringTransactions(showLoader: false)
            }
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dataStore.newRecurringTransaction()
                }, label: {
                    Image(systemName: "plus").padding()
                })
            }
        }
        .sheet(
            isPresented: $dataStore.editingRecurringTransaction,
            onDismiss: {
                dataStore.cancelEditRecurringTransaction()
            },
            content: {
                RecurringTransactionFormView(transactionForm: RecurringTransactionForm(
                    dataStore: dataStore,
                    createdBy: dataStore.currentUserId ?? "",
                    budgetId: dataStore.budgetId ?? "",
                    categoryId: dataStore.selectedRecurringTransaction?.categoryId ?? dataStore.categoryId,
                    transaction: dataStore.selectedRecurringTransaction
                ))
            })
    }
}

#if DEBUG
struct RecurringTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsListView()
    }
}
#endif

struct RecurringTransactionsListItemView: View {
    @EnvironmentObject var dataStore: DataStore
    let transaction: RecurringTransaction
    
    init (_ transaction: RecurringTransaction) {
        self.transaction = transaction
    }

    var body: some View {
        NavigationLink(
            value: transaction,
            label: {
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
        )
    }
}

#if DEBUG
struct RecurringTransactionsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionsListItemView(MockRecurringTransactionRepository.transaction)
    }
}
#endif
