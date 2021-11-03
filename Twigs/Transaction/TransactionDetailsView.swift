//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TransactionDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var shouldNavigateUp: Bool = false
    let transaction: Transaction
    
    var body: some View {
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
            .onAppear {
                if self.shouldNavigateUp {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }
    }
    
    init(_ transaction: Transaction) {
        self.transaction = transaction
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
        stateContent.onAppear {
            if let id = self.categoryId {
                categoryDataStore.getCategory(id)
            }
        }
    }
    
    var stateContent: AnyView {
        switch categoryDataStore.category {
        case .success(let category):
            return AnyView(LabeledField(label: "category", value: category.title, showDivider: true))
        default:
            return AnyView(LabeledField(label: "category", value: "", showDivider: true))
        }
    }
    
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    let categoryId: String?
    init(_ categoryId: String?) {
        self.categoryId = categoryId
    }
}

struct BudgetLineItem: View {
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    var budgetName: String {
        get {
            if case let .success(budget) = budgetDataStore.budget {
                return budget.name
            } else {
                return ""
            }
        }
    }
    
    var body: some View {
        LabeledField(label: "budget", value: budgetName, showDivider: true)
    }
}

struct UserLineItem: View {
    
    var body: some View {
        stateContent.onAppear {
            userDataStore.getUser(userId)
        }
    }
    
    var stateContent: AnyView {
        switch userDataStore.user {
        case .success(let user):
            return AnyView(LabeledField(label: "registered_by", value: user.username, showDivider: false))
        default:
            return AnyView(LabeledField(label: "registered_by", value: "", showDivider: false))
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
        TransactionDetailsView(MockTransactionRepository.transaction)
    }
}
#endif
