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
        switch self.dataStore.budget {
        case .success(let budget), .editing(let budget), .saving(let budget):
            TabView(selection: $tabSelection) {
                NavigationView {
                    BudgetDetailsView(budget: budget)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                HStack {
                                    Button("budgets", action: {
                                        self.dataStore.showBudgetSelection = true
                                    }).padding()
                                }
                            }
                        }
                        .navigationTitle(budget.name)
                }
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        Text("overview")
                    }
                    .tag(0)
                    .keyboardShortcut("1")
                NavigationSplitView(
                    sidebar: {
                        TransactionListView<EmptyView>()
                            .navigationTitle(budget.name)
                    },
                    detail: {
                        if let _ = dataStore.selectedTransaction {
                            TransactionDetailsView()
                                .navigationTitle("details")
                                .onDisappear {
                                    dataStore.selectedTransaction = nil
                                }
                        } else {
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                    })
                    .tabItem {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("transactions")
                    }
                    .tag(1)
                    .keyboardShortcut("2")
                NavigationSplitView(
                    sidebar: {
                        CategoryListView(budget)
                            .navigationTitle(budget.name)
                    },
                    content: {
                        if let _ = dataStore.selectedCategory {
                            if let budget = dataStore.selectedBudget {
                                CategoryDetailsView(budget, categoryDataStore: CategoryDataStore(dataStore.apiService))
                                    .navigationTitle(dataStore.selectedCategory?.title ?? "")
                            }
                        }
                    },
                    detail: {
                        if let _ = dataStore.selectedTransaction {
                            TransactionDetailsView()
                                .navigationTitle("details")
                        } else {
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                    })
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("categories")
                    }
                    .tag(2)
                    .keyboardShortcut("3")
                NavigationSplitView(
                    sidebar: {
                        RecurringTransactionsListView()
                            .navigationTitle(budget.name)
                    },
                    detail: {
                        if let _ = dataStore.selectedRecurringTransaction {
                            RecurringTransactionDetailsView()
                                .navigationTitle("details")
                        } else {
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                    })
                    .tabItem {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        Text("recurring")
                    }
                    .tag(3)
                    .keyboardShortcut("4")
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle.fill")
                        Text("profile")
                    }
                    .tag(4)
                    .keyboardShortcut("5")
            }
            .navigationTitle(budget.name)
        default:
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
                    BudgetListsView().environmentObject(dataStore)
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



struct TabbedBudgetView_Previews: PreviewProvider {
    @StateObject static var apiService = TwigsInMemoryCacheService()
    
    static var previews: some View {
        TabbedBudgetView()
            .environmentObject(DataStore(apiService))
            .environmentObject(apiService)
    }
}
