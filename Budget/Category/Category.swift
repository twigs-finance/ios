//
//  Category.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct Category: Identifiable, Codable {
    let budgetId: Int
    let id: Int?
    let title: String
    let description: String?
    let amount: Int
    let isExpense: Bool = true
}
