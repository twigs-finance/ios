//
//  TransactionListView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine
import Collections
import TwigsCore

struct TransactionListView<Content>: View where Content: View {
    @EnvironmentObject var dataStore: DataStore
    @State var search: String = ""
    @ViewBuilder let header: (() -> Content)?
    var addingTransaction: Bool {
        if case .editing(_) = self.dataStore.transaction {
            return true
        }
        if case .saving(_) = self.dataStore.transaction {
            return true
        }
        return false
    }

    @ViewBuilder
    private func TransactionList(_ transactions: OrderedDictionary<String, [TwigsCore.Transaction]>) -> some View {
        if transactions.isEmpty {
            Text("no_transactions")
        } else {
            if let header = header {
                Section {
                    header()
                }
            }
            ForEach(transactions.keys, id: \.self) { (key: String) in
                Group {
                    let filtered = transactions[key]!
                        .filter {
                            if let categoryId = dataStore.selectedCategory?.id {
                                if $0.categoryId != categoryId {
                                    return false
                                }
                            }
                            if !search.isEmpty {
                                return $0.title.lowercased().contains(search.lowercased())
                                    || $0.description?.lowercased().contains(search.lowercased()) ?? false
                                    || $0.amount.toCurrencyString().contains(search)
                            }

                            return true
                        }
                    if !filtered.isEmpty {
                        Section(header: Text(key)) {
                            ForEach(filtered) { transaction in
                                TransactionListItemView(transaction)
                            }
                        }
                    }
                }
            }
        }
    }

    private var currentUserId: String? {
        get {
            if case let .success(currentUser) = dataStore.currentUser {
                return currentUser.id
            } else {
                return nil
            }
        }
    }

    private var budgetId: String? {
        get {
            if case let .success(budget) = dataStore.budget {
                return budget.id
            } else {
                return nil
            }
        }
    }

    @ViewBuilder
    var body: some View {
        InlineLoadingView(
            data: $dataStore.transactions,
            action: { await dataStore.getTransactions() },
            errorTextLocalizedStringKey: "Failed to load transactions"
        ) { transactions in
            List(selection: $dataStore.selectedTransaction) {
                TransactionList(transactions)
            }
            .searchable(text: $search)
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                await dataStore.getTransactions(showLoader: false)
            }
            #endif
            .sheet(
                isPresented: .constant(addingTransaction),
                content: {
                    TransactionFormSheet(transactionForm: TransactionForm(
                        dataStore: dataStore,
                        createdBy: currentUserId ?? "",
                        budgetId: budgetId ?? "",
                        categoryId: dataStore.categoryId,
                        transaction: nil
                    ))
                })
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        dataStore.newTransaction()
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
            )
        }
    }

    init(header: (() -> Content)? = nil) {
        self.header = header
    }
}

struct TransactionListItemView: View {
    @EnvironmentObject var dataStore: DataStore
    var transaction: TwigsCore.Transaction

    var body: some View {
        NavigationLink(value: self.transaction, label: {
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
        })
    }

    init (_ transaction: TwigsCore.Transaction) {
        self.transaction = transaction
    }
}
