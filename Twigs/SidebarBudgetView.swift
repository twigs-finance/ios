//
//  SidebarBudgetView.swift
//  Twigs
//
//  Created by William Brawner on 12/7/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

struct SidebarBudgetView: View {
    @EnvironmentObject var authenticationDataStore: AuthenticationDataStore
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    let apiService: TwigsApiService
    @State var isSelectingBudget = true
    @State var hasSelectedBudget = false
    @State var isAddingTransaction = false
    @State var tabSelection: Int? = 0
    
    @ViewBuilder
    var mainView: some View {
        if case let .success(budget) = budgetDataStore.budget {
            NavigationView {
                List {
                    NavigationLink(
                        tag: 0,
                        selection: $tabSelection,
                        destination: { BudgetDetailsView(budget: budget).navigationBarTitle("overview") },
                        label: { Label("overview", systemImage: "chart.line.uptrend.xyaxis.circle.fill") }
                    )
                    .keyboardShortcut("1")
                    NavigationLink(
                        tag: 1,
                        selection: $tabSelection,
                        destination: { TransactionListView(budget).navigationBarTitle("transactions") },
                        label: { Label("transactions", systemImage: "dollarsign.circle.fill") })
                    .keyboardShortcut("2")
                    NavigationLink(
                        tag: 2,
                        selection: $tabSelection,
                        destination: { CategoryListView(budget).navigationBarTitle("categories") },
                        label: { Label("categories", systemImage: "chart.pie.fill") })
                    .keyboardShortcut("3")
                    NavigationLink(
                        tag: 3,
                        selection: $tabSelection,
                        destination: { RecurringTransactionsListView(dataStore: RecurringTransactionDataStore(apiService, budgetId: budget.id)).navigationBarTitle("recurring_transactions") },
                        label: { Label("recurring_transactions", systemImage: "arrow.triangle.2.circlepath.circle.fill") })
                    .keyboardShortcut("4")
                    BudgetListsView()
                }
                .navigationTitle(budget.name)
            }
        } else {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
    }
    
    @ViewBuilder
    var body: some View {
        mainView
        .sheet(isPresented: $authenticationDataStore.showLogin,
               onDismiss: {
            self.budgetDataStore.getBudgets()
        },
               content: {
            LoginView()
                .environmentObject(authenticationDataStore)
                .onDisappear {
                    self.budgetDataStore.getBudgets()
                }
        })
            .interactiveDismissDisabled(true)
    }
}

//struct SidebarBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SidebarBudgetView()
//    }
//}
