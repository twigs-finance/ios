//
//  BudgetDetailsView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Charts
import SwiftUI
import TwigsCore

struct BudgetDetailsView: View {
    @EnvironmentObject var dataStore: DataStore
    let budget: Budget
    
    @ViewBuilder
    var body: some View {
        InlineLoadingView(
            data: self.$dataStore.overview,
            action: { await self.dataStore.loadOverview(showLoader: false) },
            errorTextLocalizedStringKey: "budgets_load_failure"
        ) { overview in
            List {
                if let description = overview.budget.description {
                    Section(overview.budget.name) {
                        Text(description)
                    }
                }

                Section("stats") {
                    HStack {
                        VStack(alignment: .center) {
                            Text("cash_flow")
                                .font(.caption)
                            Text(verbatim: overview.balance.toCurrencyString())
                                .foregroundColor(overview.balance < 0 ? .red : .green)
                                .font(.title2)
                        }
                        Spacer()
                        VStack(alignment: .center) {
                            Text("transactions")
                                .font(.caption)
                            Text(verbatim: String(overview.transactionCount))
                                .font(.title2)

                        }
                    }
                }
                Section("expected_vs_actual") {
                    Chart {
                        BarMark(
                            x: .value("Amount", overview.expectedIncome),
                            y: .value("Label", Bundle.main.localizedString(forKey: "expected_income", value: nil, table: nil))
                        ).foregroundStyle(Color.gray)
                        BarMark(
                            x: .value("Amount", overview.actualIncome),
                            y: .value("Label", Bundle.main.localizedString(forKey: "actual_income", value: nil, table: nil))
                        ).foregroundStyle(Color.green)
                        BarMark(
                            x: .value("Amount", overview.expectedExpenses),
                            y: .value("Label", Bundle.main.localizedString(forKey: "expected_expenses", value: nil, table: nil))
                        ).foregroundStyle(Color.gray)
                        BarMark(
                            x: .value("Amount", overview.actualExpenses),
                            y: .value("Label", Bundle.main.localizedString(forKey: "actual_expenses", value: nil, table: nil))
                        ).foregroundStyle(Color.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                await dataStore.loadOverview(showLoader: false)
            }
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(
                        action: {
                            dataStore.editBudget()
                        },
                        label: { Text("edit") }
                    )
                })
            }
            .sheet(
                isPresented: $dataStore.editingBudget,
                onDismiss: { Task {
                    await dataStore.cancelEditBudget()
                }},
                content: {
                    NavigationView {
                        BudgetFormView(budget)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading, content: {
                                    Button(
                                        action: {
                                            Task {
                                                await dataStore.cancelEditBudget()
                                            }
                                        },
                                        label: { Text("cancel") }
                                    )
                                })
                            }
                            .navigationTitle("edit_budget")
                    }
                }
            )
        }
    }
}

#if DEBUG
struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDetailsView(budget: MockBudgetRepository.budget)
            .environmentObject(TwigsInMemoryCacheService())
    }
}
#endif
