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
    let budget: Budget

    @ViewBuilder
    var body: some View {
        switch budgetDataStore.overview {
        case .failure(.loading):
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        case .success(let overview):
            List {
                Section(overview.budget.name) {
                    VStack(alignment: .leading) {
                        if let description = overview.budget.description {
                            Text(description)
                        }
                        HStack {
                            Text("current_balance")
                            Text(verbatim: overview.balance.toCurrencyString())
                                .foregroundColor(overview.balance < 0 ? .red : .green)
                        }
                    }
                }
                Section("income") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("expected")
                            Text(verbatim: overview.expectedIncome.toCurrencyString())
                        }
                        ProgressView(value: Float(overview.expectedIncome), maxValue: Float(max(overview.expectedIncome, overview.actualIncome)), progressTintColor: .gray, progressBarHeight: 10.0, progressBarCornerRadius: 4.0)
                        HStack {
                            Text("actual")
                            Text(verbatim: overview.actualIncome.toCurrencyString())
                                .foregroundColor(.green)
                        }
                        ProgressView(value: Float(overview.actualIncome), maxValue: Float(max(overview.expectedIncome, overview.actualIncome)), progressTintColor: .green, progressBarHeight: 10.0, progressBarCornerRadius: 4.0)
                    }
                }
                Section("expenses") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("expected")
                            Text(verbatim: overview.expectedExpenses.toCurrencyString())
                        }
                        ProgressView(value: Float(overview.expectedExpenses), maxValue: Float(max(overview.expectedExpenses, overview.actualExpenses)), progressTintColor: .gray, progressBarHeight: 10.0, progressBarCornerRadius: 4.0)
                        HStack {
                            Text("actual")
                            Text(verbatim: overview.actualExpenses.toCurrencyString())
                                .foregroundColor(.red)
                        }
                        ProgressView(value: Float(overview.actualExpenses), maxValue: Float(max(overview.expectedExpenses, overview.actualExpenses)), progressTintColor: .red, progressBarHeight: 10.0, progressBarCornerRadius: 4.0)
                    }
                }
            }.listStyle(.insetGrouped)
            .navigationBarItems(leading: HStack {
                Button("budgets", action: {
                    self.budgetDataStore.showBudgetSelection = true
                }).padding()
            })
        default:
            Text("An error has ocurred")
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
