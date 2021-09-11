//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    @State var isAddingTransaction = false
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView {
            TransactionListView(dataStoreProvider, budget: self.budget)
                .sheet(isPresented: $isAddingTransaction, content: {
                    AddTransactionView(self.dataStoreProvider)
                        .navigationBarTitle("add_transaction")
                })
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("transactions")
                }
                .tag(0)
                .onAppear {
                    selectedTab = 0
                }
            
            BudgetListsView(dataStoreProvider).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("categories")
            }
            .onAppear {
                selectedTab = 1
            }
            
            ProfileView(dataStoreProvider).tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
            .onAppear {
                selectedTab = 2
            }
        }.navigationBarItems(
            trailing: HStack {
                NavigationLink(destination: EmptyView()) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: {
                    self.isAddingTransaction = true
                }) {
                    Image(systemName: "plus")
                        .padding()
                }
            }
        )
    }
    
    let dataStoreProvider: DataStoreProvider
    let budget: Budget
    init (_ dataStoreProvider: DataStoreProvider, budget: Budget) {
        self.dataStoreProvider = dataStoreProvider
        self.budget = budget
        // Warm up the caches
        self.dataStoreProvider.categoryDataStore().getCategories(budgetId: budget.id)
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
