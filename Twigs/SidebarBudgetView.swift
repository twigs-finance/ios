//
//  SidebarBudgetView.swift
//  Twigs
//
//  Created by William Brawner on 12/7/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct SidebarBudgetView: View {
    @EnvironmentObject var dataStore: DataStore
    @State var isSelectingBudget = true
    @State var hasSelectedBudget = false
    @State var tabSelection: Int? = 0
    
    @ViewBuilder
    var mainView: some View {
        if case let .success(budget) = self.dataStore.budget {
            NavigationSplitView(sidebar: {
                VStack {
                    List(selection: $tabSelection) {
                        NavigationLink(
                            value: 0,
                            label: { Label("overview", systemImage: "chart.line.uptrend.xyaxis") }
                        )
                        .keyboardShortcut("1")
                        NavigationLink(
                            value: 1,
                            label: { Label("transactions", systemImage: "dollarsign.circle") }
                        )
                        .keyboardShortcut("2")
                        NavigationLink(
                            value: 2,
                            label: { Label("categories", systemImage: "chart.pie") }
                        )
                        .keyboardShortcut("3")
                        NavigationLink(
                            value: 3,
                            label: { Label("recurring_transactions", systemImage: "arrow.triangle.2.circlepath") }
                        )
                        .keyboardShortcut("4")
                    }
                    BudgetListsView()
                }
                .navigationTitle(budget.name)
            }, content: {
                if tabSelection == 0, let budget = dataStore.selectedBudget {
                    BudgetDetailsView(budget: budget)
                        .navigationTitle("budgets")
                } else if tabSelection == 1 {
                    TransactionListView<EmptyView>()
                        .navigationTitle("transactions")
                } else if tabSelection == 2, let budget = dataStore.selectedBudget {
                    CategoryListView(budget)
                        .navigationTitle("categories")
                } else if tabSelection == 3 {
                    RecurringTransactionsListView()
                        .navigationTitle("recurring_transactions")
                } else {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
            }, detail: {
                if let _ = dataStore.selectedTransaction {
                    TransactionDetailsView()
                        .navigationTitle("details")
                        .onDisappear {
                            dataStore.selectedTransaction = nil
                        }
                } else if let _ = dataStore.selectedCategory {
                    if let budget = dataStore.selectedBudget {
                        CategoryDetailsView(budget, categoryDataStore: CategoryDataStore(dataStore.apiService))
                            .navigationTitle(dataStore.selectedCategory?.title ?? "")
                    }
                } else if let _ = dataStore.selectedRecurringTransaction {
                    RecurringTransactionDetailsView()
                        .navigationTitle("details")                    
                }
            })
        } else {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
    }
    
    @ViewBuilder
    var body: some View {
        mainView
            .sheet(isPresented: $dataStore.showLogin,
                   content: {
                LoginView()
                    .environmentObject(dataStore)
            })
            .interactiveDismissDisabled(true)
    }
}

//struct SidebarBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SidebarBudgetView()
//    }
//}
