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
            NavigationView {
                List {
                    NavigationLink(
                        tag: 0,
                        selection: $tabSelection,
                        destination: { BudgetDetailsView(budget: budget).navigationBarTitle("overview")
                        },
                        label: { Label("overview", systemImage: "chart.line.uptrend.xyaxis") }
                    )
                        .keyboardShortcut("1")
                    NavigationLink(
                        tag: 1,
                        selection: $tabSelection,
                        destination: { TransactionListView<EmptyView>().navigationBarTitle("transactions") },
                        label: { Label("transactions", systemImage: "dollarsign.circle") })
                        .keyboardShortcut("2")
                    NavigationLink(
                        tag: 2,
                        selection: $tabSelection,
                        destination: { CategoryListView(budget).navigationBarTitle("categories") },
                        label: { Label("categories", systemImage: "chart.pie") })
                        .keyboardShortcut("3")
                    NavigationLink(
                        tag: 3,
                        selection: $tabSelection,
                        destination: { RecurringTransactionsListView().navigationBarTitle("recurring_transactions") },
                        label: { Label("recurring_transactions", systemImage: "arrow.triangle.2.circlepath") })
                        .keyboardShortcut("4")
                    BudgetListsView()
                }
                .navigationTitle(budget.name)
                EmptyView()
                if self.tabSelection ?? 0 > 0 {
                    EmptyView()
                }
            }
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
