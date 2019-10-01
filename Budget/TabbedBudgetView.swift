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
    let budgetRepository: BudgetRepository
    
    var body: some View {
        TabView {
            Text("Transactions here").tabItem {
                Image(systemName: "dollarsign.circle.fill")
                Text("transactions")
            }
            BudgetsView(BudgetsDataStore(budgetRepository)).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("budgets")
            }
            Text("Profile here").tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
        }
    }
    
    init (_ userData: UserDataStore, budgetRepository: BudgetRepository) {
        self.userData = userData
        self.budgetRepository = budgetRepository
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
