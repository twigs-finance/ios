//
//  Transaction.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI
import TwigsCore

extension TransactionType {
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
}

extension TwigsCore.Transaction {
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
