//
//  Budget.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct Budget: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String?
    let currencyCode: String?
}

struct BudgetOverview {
    let budget: Budget
    let balance: Int
    var expectedIncome: Int = 0
    var actualIncome: Int = 0
    var expectedExpenses: Int = 0
    var actualExpenses: Int = 0
}
