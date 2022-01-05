//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct TransactionDetailsView: View {
    @EnvironmentObject var apiService: TwigsApiService
    @EnvironmentObject var authDataStore: AuthenticationDataStore
    @EnvironmentObject var dataStore: TransactionDataStore
    @ObservedObject var transactionDetails: TransactionDetails
    var editing: Bool {
        if case .editing(_) = dataStore.transaction {
            return true
        }
        if case .saving(_) = dataStore.transaction {
            return true
        }
        return false
    }
    
    init(_ transactionDetails: TransactionDetails) {
        self.transactionDetails = transactionDetails
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
                    CategoryLineItem()
                    BudgetLineItem()
                    UserLineItem()
                }.padding()
                    .environmentObject(transactionDetails)
                    .task {
                        await transactionDetails.loadDetails(transaction)
                    }
            }
            .navigationBarItems(trailing: Button(
                action: { self.dataStore.editTransaction(transaction) }
            ) {
                Text("edit")
            })
            .sheet(isPresented: .constant(self.editing), onDismiss: nil) {
                TransactionFormSheet(transactionForm: TransactionForm(
                    budgetRepository: apiService,
                    categoryRepository: apiService,
                    transactionList: dataStore,
                    createdBy: authDataStore.currentUser!.id,
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
        if let val = value, !val.isEmpty {
            VStack {
                HStack {
                    Text(self.label)
                        .foregroundColor(.secondary)
                    Spacer()
                    if loading {
                        EmbeddedLoadingView()
                    } else {
                        Text(verbatim: val)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if showDivider {
                    Divider()
                }
            }
        }
    }
}

struct CategoryLineItem: View {
    @EnvironmentObject var transactionDetails: TransactionDetails
    var value: String {
        // TODO: Show errors
        if case let .success(category) = transactionDetails.category {
            return category.title
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        if case .empty = transactionDetails.category {
            EmptyView()
        } else {
            LabeledField(label: "category", value: value, loading: .constant(self.value == ""), showDivider: true)
        }
    }
}

struct BudgetLineItem: View {
    @EnvironmentObject var transactionDetails: TransactionDetails
    var value: String {
        // TODO: Show errors
        if case let .success(budget) = transactionDetails.budget {
            return budget.name
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        if case .empty = transactionDetails.budget {
            EmptyView()
        } else {
            LabeledField(label: "budget", value: value, loading: .constant(self.value == ""), showDivider: true)
        }
    }
}

struct UserLineItem: View {
    @EnvironmentObject var transactionDetails: TransactionDetails
    var value: String {
        // TODO: Show errors
        if case let .success(user) = transactionDetails.user {
            return user.username
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    var body: some View {
        if case .empty = transactionDetails.user {
            EmptyView()
        } else {
            LabeledField(label: "created_by", value: value, loading: .constant(self.value == ""), showDivider: false)
        }
    }
}

#if DEBUG
struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView(TransactionDetails(budgetRepository: MockBudgetRepository(), categoryRepository: MockCategoryRepository(), userRepository: MockUserRepository()))
    }
}
#endif
