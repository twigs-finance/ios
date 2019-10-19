//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    @ObservedObject var userData: AuthenticationDataStore
    @State var isAddingTransaction = false
    
    var body: some View {
        TabView {
            NavigationView {
                TransactionListView(dataStoreProvider)
                    .navigationBarTitle("transactions")
                    .navigationBarItems(
                        leading: NavigationLink(destination: EmptyView()) {
                            Text("filter")
                        },
                        trailing: Button(action: {
                            self.isAddingTransaction = true
                        }) {
                            Image(systemName: "plus")
                            .padding()
                        }
                )
            }
            .tabItem {
                Image(systemName: "dollarsign.circle.fill")
                Text("transactions")
            }
            
            BudgetListsView(dataStoreProvider).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("budgets")
            }
            
            ProfileView(dataStoreProvider).tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
        }.edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $isAddingTransaction, content: {
            AddTransactionView(self.dataStoreProvider)
                .navigationBarTitle("add_transaction")
        })
    }
    
    let dataStoreProvider: DataStoreProvider
    init (_ userData: AuthenticationDataStore, dataStoreProvider: DataStoreProvider) {
        self.userData = userData
        self.dataStoreProvider = dataStoreProvider
        // Warm up the caches
        self.dataStoreProvider.budgetsDataStore().getBudgets()
        self.dataStoreProvider.categoryDataStore().getCategories()
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
