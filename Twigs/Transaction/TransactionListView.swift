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
    @EnvironmentObject var authDataStore: AuthenticationDataStore
    @StateObject var transactionDataStore: TransactionDataStore
    let apiService: TwigsApiService
    @State var search: String = ""
    @ViewBuilder let header: (() -> Content)?
    var addingTransaction: Bool {
        if case .editing(_) = self.transactionDataStore.transaction {
            return true
        }
        if case .saving(_) = self.transactionDataStore.transaction {
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
                    let filtered = search.isEmpty ? transactions[key]! : transactions[key]!.filter { $0.title.lowercased().contains(search.lowercased())
                        || $0.description?.lowercased().contains(search.lowercased()) ?? false
                        || $0.amount.toCurrencyString().contains(search)
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
    
    @ViewBuilder
    var body: some View {
        InlineLoadingView(
            data: $transactionDataStore.transactions,
            action: { await transactionDataStore.getTransactions(self.budget.id, categoryId: self.category?.id) },
            errorTextLocalizedStringKey: "Failed to load transactions"
        ) { transactions in
            List {
                TransactionList(transactions)
            }
            .searchable(text: $search)
            .sheet(
                isPresented: .constant(addingTransaction),
                content: {
                    TransactionFormSheet(transactionForm: TransactionForm(
                        budgetRepository: apiService,
                        categoryRepository: apiService,
                        transactionList: transactionDataStore,
                        createdBy: authDataStore.currentUser!.id,
                        budgetId: self.budget.id,
                        categoryId: self.category?.id,
                        transaction: nil
                    ))
                    .navigationBarTitle("add_transaction")
            })
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        transactionDataStore.editTransaction(TwigsCore.Transaction(createdBy: authDataStore.currentUser!.id, budgetId: budget.id))
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
            )
        }
    }
    
    let budget: Budget
    let category: TwigsCore.Category?
    init(apiService: TwigsApiService, budget: Budget, category: TwigsCore.Category? = nil, header: (() -> Content)? = nil) {
        self.apiService = apiService
        self._transactionDataStore = StateObject(wrappedValue: TransactionDataStore(apiService))
        self.budget = budget
        self.category = category
        self.header = header
    }
}

struct TransactionListItemView: View {
    @EnvironmentObject var dataStore: TransactionDataStore
    @EnvironmentObject var apiService: TwigsApiService
    var transaction: TwigsCore.Transaction
    
    var body: some View {
        NavigationLink(
            tag: self.transaction,
            selection: self.$dataStore.selectedTransaction,
            destination: {
                TransactionDetailsView(TransactionDetails(
                    budgetRepository: apiService,
                    categoryRepository: apiService,
                    userRepository: apiService
                )).navigationBarTitle("details", displayMode: .inline)
            },
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
    
    init (_ transaction: TwigsCore.Transaction) {
        self.transaction = transaction
    }
}
