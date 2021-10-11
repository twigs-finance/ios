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
                    Text("Current Balance:")
                    Text(verbatim: overview.balance.toCurrencyString())
                        .foregroundColor(overview.balance < 0 ? .red : .green)
                    Text("Expected Income:")
                    Text(verbatim: overview.expectedIncome.toCurrencyString())
                    Text("Actual Income:")
                    Text(verbatim: overview.actualIncome.toCurrencyString())
                        .foregroundColor(.green)
                    Text("Expected Expenses:")
                    Text(verbatim: overview.expectedExpenses.toCurrencyString())
                    Text("Actual Expenses:")
                    Text(verbatim: overview.actualExpenses.toCurrencyString())
                        .foregroundColor(.red)
                default:
                    Text("An error has ocurred")
                }
            }.onAppear {
                if requestedOverview != budget.id {
                    print("requesting overview")
                    requestedOverview = budget.id
                    budgetDataStore.loadOverview(budget)
                }
            }
        }
    }
}

struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDetailsView(budget: MockBudgetRepository.budget)
    }
}
