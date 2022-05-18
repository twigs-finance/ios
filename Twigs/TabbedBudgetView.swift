//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct TabbedBudgetView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var apiService: TwigsApiService
    @AppStorage("budget_tab") var tabSelection: Int = 0
    
    @ViewBuilder
    var mainView: some View {
        if case let .success(budget) = dataStore.budget {
            TabView(selection: $tabSelection) {
                NavigationView {
                    BudgetDetailsView(budget: budget)
                        .navigationBarTitle("overview")
                        .navigationBarItems(leading: HStack {
                            Button("budgets", action: {
                                self.dataStore.showBudgetSelection = true
                            }).padding()
                        }, trailing: Button("logout", action: {
                            self.dataStore.logout()
                        }).padding())
                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    Text("overview")
                }
                .tag(0)
                .keyboardShortcut("1")
                NavigationView {
                    TransactionListView<EmptyView>()
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
                    RecurringTransactionsListView()
                        .navigationBarTitle("recurring_transactions")
                }
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    Text("recurring")
                }
                .tag(3)
                .keyboardShortcut("4")
            }
        } else {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
    }
    
    var body: some View {
        mainView.sheet(isPresented: $dataStore.showLogin,
                       content: {
            LoginView()
                .environmentObject(dataStore)
                .interactiveDismissDisabled(true)
        })
        
        .sheet(isPresented: $dataStore.showBudgetSelection,
                 content: {
            NavigationView {
                VStack {
                    List {
                        BudgetListsView().environmentObject(dataStore)
                    }
                    .navigationTitle("budgets")
                    .navigationBarItems(trailing: Button(action: {dataStore.newBudget()}, label: {
                        Image(systemName: "plus")
                            .padding()
                    }))
                    NavigationLink(
                        isActive: self.$dataStore.editingBudget,
                        destination: { BudgetFormView().navigationTitle("new_budget") },
                        label: { EmptyView() }
                    )
                }
            }
            .interactiveDismissDisabled(true)
        })
    }
}


//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
