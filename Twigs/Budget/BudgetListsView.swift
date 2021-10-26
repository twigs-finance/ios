
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
    @EnvironmentObject var budgetsDataStore: BudgetsDataStore
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            switch budgetsDataStore.budgets {
            case .success(let budgets):
                Section {
                    List(budgets) { budget in
                        BudgetListItemView(budget)
                    }
                }.navigationBarTitle("budgets")
            case .failure(.loading):
                VStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }.navigationBarTitle("budgets")
            default:
                // TODO: Handle each network failure type
                Text("budgets_load_failure").navigationBarTitle("budgets")
                Button("action_retry", action: {
                    self.budgetsDataStore.getBudgets()
                })
            }
        }.onAppear {
            self.budgetsDataStore.getBudgets()
        }
        
    }
}

struct BudgetListItemView: View {
    @EnvironmentObject var budgetsDataStore: BudgetsDataStore
    var budget: Budget
    
    var body: some View {
        NavigationLink(
            budget.name,
            tag: budget,
            selection: $budgetsDataStore.budget,
            destination: {
                TabbedBudgetView(budget)
                .navigationBarTitle(budget.name)
            }
        )
    }
    
    init (_ budget: Budget) {
        self.budget = budget
    }
}

#if DEBUG
struct BudgetListsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListsView()
    }
}
#endif
