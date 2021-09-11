
//
//  BudgetsView.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct BudgetListsView: View {
    @ObservedObject var budgetsDataStore: BudgetsDataStore
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            switch budgetsDataStore.budgets {
            case .success(let budgets):
                Section {
                    List(budgets) { budget in
                        BudgetListItemView(self.dataStoreProvider, budget: budget)
                    }
                }.navigationBarTitle("budgets")
            case .failure(.loading):
                VStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }.navigationBarTitle("budgets")
            default:
                // TODO: Handle each network failure type
                Text("budgets_load_failure").navigationBarTitle("budgets")
            }
        }
        
    }
    
    
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider) {
        self.dataStoreProvider = dataStoreProvider
        self.budgetsDataStore = dataStoreProvider.budgetsDataStore()
        self.budgetsDataStore.getBudgets()
    }
}

struct BudgetListItemView: View {
    var budget: Budget
    let dataStoreProvider: DataStoreProvider
    
    var body: some View {
        NavigationLink(
            destination: TabbedBudgetView(self.dataStoreProvider, budget: budget)
                .navigationBarTitle(budget.name)
        ) {
            VStack(alignment: .leading) {
                Text(verbatim: budget.name)
                    .lineLimit(1)
                if budget.description?.isEmpty == false {
                    Text(verbatim: budget.description!)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    init (_ dataStoreProvider: DataStoreProvider, budget: Budget) {
        self.dataStoreProvider = dataStoreProvider
        self.budget = budget
    }
}

#if DEBUG
struct BudgetListsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListsView(MockDataStoreProvider())
    }
}
#endif
