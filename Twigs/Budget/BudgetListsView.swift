
//
//  BudgetsView.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine
import TwigsCore

struct BudgetListsView: View {
    @EnvironmentObject var dataStore: DataStore
    
    var body: some View {
        InlineLoadingView(
            data: $dataStore.budgets,
            action: { await self.dataStore.getBudgets(count: nil, page: nil) },
            errorTextLocalizedStringKey: "budgets_load_failure"
        ) { (budgets: [Budget]) in
            Section("budgets") {
                ForEach(budgets) { budget in
                    BudgetListItemView(budget)
                }
            }
        }
    }
}

struct BudgetListItemView: View {
    @EnvironmentObject var dataStore: DataStore
    let budget: Budget
    
    var body: some View {
        Button(
            action: {
                Task {
                    await self.dataStore.selectBudget(budget)
                }
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
