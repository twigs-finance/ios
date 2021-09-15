//
//  Category.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct Category: Identifiable, Hashable, Codable {
    let budgetId: String
    let id: String
    let title: String
    let description: String?
    let amount: Int
    let expense: Bool
    let archived: Bool
}
