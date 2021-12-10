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
    @StateObject var budgetDataStore: BudgetsDataStore
    let apiService: TwigsApiService
    @State var isSelectingBudget = true
    @State var hasSelectedBudget = false
    @State var isAddingTransaction = false
    @State var tabSelection: Int = 0
    
    init(_ apiService: TwigsApiService) {
        self.apiService = apiService
        self._budgetDataStore = StateObject(wrappedValue: BudgetsDataStore(budgetRepository: apiService, categoryRepository: apiService, transactionRepository: apiService))
    }
    
    @ViewBuilder
    var mainView: some View {
        if case let .success(budget) = budgetDataStore.budget {
            TabView(selection: $tabSelection) {
                NavigationView {
                    BudgetDetailsView(budget: budget)
                        .navigationBarTitle("overview")
                        .navigationBarItems(leading: HStack {
                            Button("budgets", action: {
                                self.budgetDataStore.showBudgetSelection = true
                            }).padding()
                        })
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
                    RecurringTransactionsListView(dataStore: RecurringTransactionDataStore(apiService, budgetId: budget.id))
                        .navigationBarTitle("recurring_transactions")
                }
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    Text("recurring")
                }
                .tag(3)
                .keyboardShortcut("4")
            }.environmentObject(TransactionDataStore(apiService))
                .environmentObject(CategoryDataStore(apiService))
                .environmentObject(budgetDataStore)
                .environmentObject(UserDataStore(apiService))
        } else {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
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
                .onDisappear {
                    self.budgetDataStore.getBudgets()
                }
        }).sheet(isPresented: $budgetDataStore.showBudgetSelection,
                 content: {
            List {
                BudgetListsView()
            }
        })
            .interactiveDismissDisabled(true)
    }
}


//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
