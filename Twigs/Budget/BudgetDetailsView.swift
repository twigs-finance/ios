//
//  BudgetDetailsView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct BudgetDetailsView: View {
    @EnvironmentObject var transactionDataStore: TransactionDataStore
    @State var sumId: String = ""
    let budget: Budget

    @ViewBuilder
    var body: some View {
        ScrollView {
            VStack {
                switch transactionDataStore.sums[sumId] {
                case .failure(.loading):
                    ActivityIndicator(isAnimating: .constant(true), style: .large).onAppear {
                        if self.sumId == "" {
                            self.sumId = transactionDataStore.sum(budgetId: self.budget.id)
                        }
                    }
                case .success(let sum):
                    Text("Current Balance:")
                    Text(verbatim: sum.balance.toCurrencyString())
                        .foregroundColor(sum.balance < 0 ? .red : .green)
                default:
                    Text("An error has ocurred")
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
