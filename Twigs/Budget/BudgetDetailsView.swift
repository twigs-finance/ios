//
//  BudgetDetailsView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct BudgetDetailsView: View {
    @EnvironmentObject var budgetDataStore: BudgetsDataStore
    @State var requestedOverview = ""
    let budget: Budget

    @ViewBuilder
    var body: some View {
        ScrollView {
            VStack {
                switch budgetDataStore.overview {
                case .failure(.loading):
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                case .success(let overview):
                    Text("current_balance")
                    Text(verbatim: overview.balance.toCurrencyString())
                        .foregroundColor(overview.balance < 0 ? .red : .green)
                    Text("expected_income")
                    Text(verbatim: overview.expectedIncome.toCurrencyString())
                    Text("actual_income")
                    Text(verbatim: overview.actualIncome.toCurrencyString())
                        .foregroundColor(.green)
                    Text("expected_expenses")
                    Text(verbatim: overview.expectedExpenses.toCurrencyString())
                    Text("actual_expenses")
                    Text(verbatim: overview.actualExpenses.toCurrencyString())
                        .foregroundColor(.red)
                default:
                    Text("An error has ocurred")
                }
            }.onAppear {
                if requestedOverview != budget.id {
                    requestedOverview = budget.id
                    budgetDataStore.loadOverview(budget)
                }
            }
        }
    }
}

#if DEBUG
struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDetailsView(budget: MockBudgetRepository.budget)
            .environmentObject(BudgetsDataStore(budgetRepository: MockBudgetRepository(), categoryRepository: MockCategoryRepository(), transactionRepository: MockTransactionRepository()))
    }
}
#endif
