//
//  Transaction.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: Int?
    let title: String
    let description: String?
    let date: Date
    let amount: Int
    let categoryId: Int?
    let expense: Bool = true
    let createdBy: Int
    let budgetId: Int
}
