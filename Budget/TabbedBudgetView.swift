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
        NavigationView {
            TabView {
                Text("Transactions here")
                    .tabItem {
                        Image(systemName: "dollarsign.circle")
                        Text("transactions")
                    }
                Text("Budgets here")
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("budgets")
                    }
                Text("Profile here")
                    .tabItem {
                        Image(systemName: "person")
                        Text("profile")
                    }
            }
        }
    }
    
    init (_ userData: UserDataStore) {
        self.userData = userData
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
