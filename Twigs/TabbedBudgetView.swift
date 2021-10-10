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
    @State var categoryRequestId: String = ""
    
    var body: some View {
        TabView {
            BudgetDetailsView(budget: self.budget)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    Text("Overview")
                }
                .tag(0)
                .onAppear {
                    if categoryRequestId == "" {
                        categoryRequestId = categoryDataStore.getCategories(budgetId: budget.id, archived: false)
                    }
                }
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
            
            // TODO: Figure out why this is breaking when requestId is set from inside CategoryListView
            CategoryListView(self.budget, requestId: categoryRequestId).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("categories")
            }
            
            ProfileView().tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
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
