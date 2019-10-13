//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TransactionDetailsView: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch transactionDataStore.transaction {
        case .success(let transaction):
            return AnyView(ScrollView {
                VStack(alignment: .leading) {
                    Text(transaction.title)
                        .font(.title)
                    Text(transaction.amount.toCurrencyString() ?? "")
                        .font(.headline)
                        .foregroundColor(transaction.expense ? .red : .green)
                        .multilineTextAlignment(.trailing)
                    Spacer().frame(height: 10)
                    Text(transaction.date.toLocaleString())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer().frame(height: 20.0)
                    LabeledField(label: "notes", value: transaction.description, showDivider: true)
                    CategoryLineItem(self.dataStoreProvider, categoryId: transaction.categoryId)
                    BudgetLineItem(self.dataStoreProvider, budgetId: transaction.budgetId)
                    UserLineItem(self.dataStoreProvider, userId: transaction.createdBy)
                }.padding()
            }
            .navigationBarItems(trailing: NavigationLink(destination: EmptyView()) {
                Text("edit")
            }))
        case .failure(.loading):
            return AnyView(EmbeddedLoadingView())
        default:
            return AnyView(Text("transaction_details_error"))
        }
    }
        
    let dataStoreProvider: DataStoreProvider
    @ObservedObject var transactionDataStore: TransactionDataStore
    init(_ dataStoreProvider: DataStoreProvider, transactionId: Int) {
        self.dataStoreProvider = dataStoreProvider
        let transactionDataStore = dataStoreProvider.transactionDataStore()
        transactionDataStore.getTransaction(transactionId)
        self.transactionDataStore = transactionDataStore
    }
}

struct LabeledField: View {
    let label: LocalizedStringKey
    let value: String?
    let showDivider: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(self.label)
                    .foregroundColor(.secondary)
                Spacer()
                Text(verbatim: value ?? "")
                    .multilineTextAlignment(.trailing)
            }
            if showDivider {
                Divider()
            }
        }
    }
}

struct CategoryLineItem: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch categoryDataStore.category {
        case .success(let category):
            return AnyView(LabeledField(label: "category", value: category.title, showDivider: true))
        default:
            return AnyView(LabeledField(label: "category", value: "", showDivider: true))
        }
    }
    
    @ObservedObject var categoryDataStore: CategoryDataStore
    init(_ dataStoreProvider: DataStoreProvider, categoryId: Int?) {
        let categoryDataStore = dataStoreProvider.categoryDataStore()
        if let id = categoryId {
            categoryDataStore.getCategory(id)
        }
        self.categoryDataStore = categoryDataStore
    }
}

struct BudgetLineItem: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch budgetDataStore.budget {
        case .success(let budget):
            return AnyView(LabeledField(label: "budget", value: budget.name, showDivider: true))
        default:
            return AnyView(LabeledField(label: "budget", value: "", showDivider: true))
        }
    }
    
    @ObservedObject var budgetDataStore: BudgetsDataStore
    init(_ dataStoreProvider: DataStoreProvider, budgetId: Int) {
        let budgetDataStore = dataStoreProvider.budgetsDataStore()
        budgetDataStore.getBudget(budgetId)
        self.budgetDataStore = budgetDataStore
    }
}

struct UserLineItem: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch userDataStore.user {
        case .success(let user):
            return AnyView(LabeledField(label: "registered_by", value: user.username, showDivider: false))
        default:
            return AnyView(LabeledField(label: "registered_by", value: "", showDivider: false))
        }
    }
    
    @ObservedObject var userDataStore: UserDataStore
    init(_ dataStoreProvider: DataStoreProvider, userId: Int) {
        let userDataStore = dataStoreProvider.userDataStore()
        userDataStore.getUser(userId)
        self.userDataStore = userDataStore
    }
}

struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView(MockDataStoreProvider(), transactionId: 2)
    }
}
