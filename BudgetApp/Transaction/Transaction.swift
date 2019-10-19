//
//  Transaction.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Hashable, Codable {
    let id: Int?
    let title: String
    let description: String?
    let date: Date
    let amount: Int
    let categoryId: Int?
    let expense: Bool
    let createdBy: Int
    let budgetId: Int
}

enum TransactionType: Int, CaseIterable, Identifiable, Hashable {
    case expense
    case income
    
    var localizedKey: LocalizedStringKey {
        var key: String
        switch self {
        case .expense:
            key = "type_expense"
        case .income:
            key = "type_income"
        }
        return LocalizedStringKey(key)
    }
    
    var id: TransactionType { self }
}

extension Transaction {
    var type: TransactionType {
        if (self.expense) {
            return .expense
        } else {
            return .income
        }
    }
    
    var amountString: String {
        return String(Double(self.amount) / 100.0)
    }
}
