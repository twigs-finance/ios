//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    @EnvironmentObject var authenticationDataStore: AuthenticationDataStore
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    @State var isSelectingBudget = true
    @State var hasSelectedBudget = false
    @State var isAddingTransaction = false
    @State var tabSelection: Int = 0
    
    @ViewBuilder
    var mainView: some View {
        if case let .success(budget) = budgetDataStore.budget {
            TabView(selection: $tabSelection) {
                NavigationView {
                    BudgetDetailsView(budget: budget)
                        .navigationBarTitle("overview")
                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    Text("overview")
                }
                .tag(0)
                .keyboardShortcut("1")
                NavigationView {
                    TransactionListView(budget)
                        .sheet(isPresented: $isAddingTransaction,
                               onDismiss: {
                            isAddingTransaction = false
                        },
                               content: {
                            AddTransactionView(showSheet: self.$isAddingTransaction, budgetId: budget.id)
                                .navigationBarTitle("add_transaction")
                        })
                        .navigationBarTitle("transactions")
                }
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("transactions")
                }
                .tag(1)
                .keyboardShortcut("2")
                NavigationView {
                    CategoryListView(budget)
                        .navigationBarTitle("categories")
                }
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("categories")
                }
                .tag(2)
                .keyboardShortcut("3")
                NavigationView {
                    ProfileView()
                        .navigationBarTitle("profile")
                }
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("profile")
                }
                .tag(3)
                .keyboardShortcut("4")
            }
        } else {
            Text("Loading…")
        }
    }
    
    var body: some View {
        mainView.sheet(isPresented: $authenticationDataStore.showLogin,
                       onDismiss: {
            self.budgetDataStore.getBudgets()
        },
                       content: {
            LoginView()
                .environmentObject(authenticationDataStore)
        }).sheet(isPresented: $budgetDataStore.showBudgetSelection,
                 content: {
            BudgetListsView()
                .environmentObject(budgetDataStore)
        })
            .interactiveDismissDisabled(!hasSelectedBudget)
    }
}


//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
