//
//  BudgetDetailsView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct BudgetDetailsView: View {
    var body: some View {
        ScrollView {
            VStack {
//                ProgressView(value: .constant(50.0, maxValue: 100))
//                CategoryListView(budget)
            }
        }
    }
    
    let dataStoreProvider: DataStoreProvider
    let budget: Budget
    init(_ dataStoreProvider: DataStoreProvider, budget: Budget) {
        self.dataStoreProvider = dataStoreProvider
        self.budget = budget
    }
}

struct BudgetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetDetailsView(MockDataStoreProvider(), budget: MockBudgetRepository.budget)
    }
}
