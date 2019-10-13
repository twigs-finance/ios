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
                        }
                )
                    .sheet(isPresented: $isAddingTransaction, content: {
                        AddTransactionView(self.dataStoreProvider)
                    })
            }
            .tabItem {
                Image(systemName: "dollarsign.circle.fill")
                Text("transactions")
            }
            
            BudgetListsView(dataStoreProvider).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("budgets")
            }
            
            Text("Profile here").tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
        }.edgesIgnoringSafeArea(.top)
    }
    
    let dataStoreProvider: DataStoreProvider
    init (_ userData: AuthenticationDataStore, dataStoreProvider: DataStoreProvider) {
        self.userData = userData
        self.dataStoreProvider = dataStoreProvider
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
