//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    let budget: Budget
    @State var isAddingTransaction = false
    @State var tabSelection: Int = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            BudgetDetailsView(budget: self.budget)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    Text("Overview")
                }
                .tag(0)
            TransactionListView(self.budget)
                .sheet(isPresented: $isAddingTransaction,
                       onDismiss: {
                    isAddingTransaction = false
                },
                       content: {
                    AddTransactionView(showSheet: self.$isAddingTransaction, budgetId: self.budget.id)
                        .navigationBarTitle("add_transaction")
                })
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("transactions")
                }
                .tag(1)
            
            CategoryListView(self.budget).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("categories")
            }
            .tag(2)
            
            ProfileView().tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
            .tag(3)
        }.navigationBarItems(
            trailing: HStack {
                if tabSelection == 1 {
                    Button(action: {
                        self.isAddingTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
            }
        )
    }
    
    init (_ budget: Budget) {
        self.budget = budget
    }
}
//
//struct TabbedBudgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedBudgetView()
//    }
//}
