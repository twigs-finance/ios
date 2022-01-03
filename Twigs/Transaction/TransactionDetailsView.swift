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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: TransactionDataStore
    @State var shouldNavigateUp: Bool = false
        
    var body: some View {
        if let transaction = self.dataStore.transaction {
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
                    LabeledField(label: "notes", value: transaction.description, showDivider: true)
                    CategoryLineItem(transaction.categoryId)
                    BudgetLineItem()
                    UserLineItem(transaction.createdBy)
                }.padding()
            }
            .navigationBarItems(trailing: NavigationLink(
                destination: TransactionEditView(
                    transaction,
                    shouldNavigateUp: self.$shouldNavigateUp
                ).navigationBarTitle("edit")
            ) {
                Text("edit")
            })
        } else {
            EmbeddedLoadingView().onAppear {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LabeledField: View {
    let label: LocalizedStringKey
    let value: String?
    let showDivider: Bool
    
    @ViewBuilder
    var body: some View {
        if let val = value, !val.isEmpty {
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
}

struct CategoryLineItem: View {
    var body: some View {
        stateContent.onAppear {
            if let id = self.categoryId {
                Task {
                    try await categoryDataStore.getCategory(id)
                }
            }
        }
    }
    
    @ViewBuilder
    var stateContent: some View {
        if let category = self.categoryDataStore.category {
            LabeledField(label: "category", value: category.title, showDivider: true)
        } else {
            LabeledField(label: "category", value: "", showDivider: true)
        }
    }
    
    @EnvironmentObject var categoryDataStore: CategoryListDataStore
    let categoryId: String?
    init(_ categoryId: String?) {
        self.categoryId = categoryId
    }
}

struct BudgetLineItem: View {
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    
    var body: some View {
        LabeledField(label: "budget", value: self.budgetDataStore.budget?.name, showDivider: true)
    }
}

struct UserLineItem: View {
    
    var body: some View {
        LabeledField(label: "registered_by", value: userDataStore.user?.username, showDivider: false).onAppear {
            Task {
                try await userDataStore.getUser(userId)
            }
        }
    }
        
    @EnvironmentObject var userDataStore: UserDataStore
    let userId: String
    init(_ userId: String) {
        self.userId = userId
    }
}

#if DEBUG
struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView()
    }
}
#endif
