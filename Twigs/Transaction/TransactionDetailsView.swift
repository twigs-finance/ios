//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore
import ArgumentParser

struct TransactionDetailsView: View {
    @EnvironmentObject var apiService: TwigsApiService
    @EnvironmentObject var dataStore: DataStore
    var editing: Bool {
        if case .editing(_) = dataStore.transaction {
            return true
        }
        if case .saving(_) = dataStore.transaction {
            return true
        }
        return false
    }
    
    private var currentUserId: String? {
        get {
            if case let .success(currentUser) = self.dataStore.currentUser {
                return currentUser.id
            } else {
                return nil
            }
        }
    }
    
    var body: some View {
        if let transaction = self.dataStore.selectedTransaction {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(transaction.title)
                        .font(.title)
                    Text(transaction.amount.toCurrencyString())
                        .font(.headline)
                        .foregroundColor(transaction.expense ? .red : .green)
                        .multilineTextAlignment(.trailing)
                    Spacer().frame(height: 10)
                    Text(transaction.date.toLocaleString())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer().frame(height: 20.0)
                    if let description = transaction.description {
                        LabeledField(label: "notes", value: description, loading: .constant(false), showDivider: true)
                    }
                    if let categoryId = transaction.categoryId {
                        CategoryLineItem(id: categoryId)
                    }
                    BudgetLineItem(id: transaction.budgetId)
                    UserLineItem(id: transaction.createdBy)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(
                action: { self.dataStore.editTransaction(transaction) }
            ) {
                Text("edit")
            })
            .sheet(isPresented: .constant(self.editing), onDismiss: nil) {
                TransactionFormSheet(transactionForm: TransactionForm(
                    dataStore: dataStore,
                    createdBy: currentUserId!,
                    budgetId: transaction.budgetId,
                    categoryId: transaction.categoryId,
                    transaction: transaction
                ))
            }
        } else {
            EmbeddedLoadingView()
        }
    }
}

struct LabeledField: View {
    let label: LocalizedStringKey
    let value: String?
    @Binding var loading: Bool
    let showDivider: Bool
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Text(self.label)
                    .foregroundColor(.secondary)
                Spacer()
                if loading {
                    EmbeddedLoadingView()
                } else {
                    Text(verbatim: self.value ?? "")
                        .multilineTextAlignment(.trailing)
                }
            }
            if showDivider {
                Divider()
            }
        }
    }
}

struct CategoryLineItem: View {
    let id: String
    @EnvironmentObject var dataStore: DataStore
    var value: String {
        // TODO: Show errors
        if let category = dataStore.getCategory(id) {
            return category.title
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        LabeledField(label: "category", value: value, loading: .constant(self.value == ""), showDivider: true)
    }
}

struct BudgetLineItem: View {
    let id: String
    @EnvironmentObject var dataStore: DataStore
    var value: String {
        // TODO: Show errors
        if let budget = dataStore.getBudget(id) {
            return budget.name
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        LabeledField(label: "budget", value: value, loading: .constant(self.value == ""), showDivider: true)
    }
}

struct UserLineItem: View {
    let id: String
    @EnvironmentObject var dataStore: DataStore
    var value: String {
        // TODO: Show errors
        if case let .success(user) = dataStore.user, user.id == id {
            return user.username
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        LabeledField(label: "created_by", value: value, loading: .constant(self.value == ""), showDivider: false)
            .task {
                await dataStore.getUser(id)
            }
    }
}

#if DEBUG
struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView()
    }
}
#endif
