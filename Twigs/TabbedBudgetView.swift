//
//  TabbedBudgetView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TabbedBudgetView: View {
    let budget: Budget
    @State var isAddingTransaction = false
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView {
            TransactionListView(self.budget)
                .sheet(isPresented: $isAddingTransaction, content: {
                    AddTransactionView(budgetId: self.budget.id)
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
            
            CategoryListView(self.budget).tabItem {
                Image(systemName: "chart.pie.fill")
                Text("categories")
            }
            .tag(1)
            .onAppear {
                selectedTab = 1
            }
            
            ProfileView().tabItem {
                Image(systemName: "person.circle.fill")
                Text("profile")
            }
            .tag(2)
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
