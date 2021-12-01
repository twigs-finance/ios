
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
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            switch budgetDataStore.budgets {
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
                    self.budgetDataStore.getBudgets()
                })
            }
        }
    }
}

struct BudgetListItemView: View {
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    let budget: Budget

    var body: some View {
        Button(
            action: {
                self.budgetDataStore.selectBudget(budget)
            },
            label: {
                VStack(alignment: .leading) {
                    Text(verbatim: budget.name)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if budget.description?.isEmpty == false {
                        Text(verbatim: budget.description!)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
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
