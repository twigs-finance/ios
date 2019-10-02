//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    @ObservedObject var userData: UserDataStore
    
    var body: some View {
        TabView {
            NavigationView {
                TransactionListView(dataStoreProvider)
                    .navigationBarTitle("transactions")
            }.tabItem {
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
        }
    }
    
    let dataStoreProvider: DataStoreProvider
    init (_ userData: UserDataStore, dataStoreProvider: DataStoreProvider) {
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
