//
//  RecurringTransactionDetailsView.swift
//  Twigs
//
//  Created by William Brawner on 12/7/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

struct RecurringTransactionDetailsView: View {
    let transaction: RecurringTransaction
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.title)
                Text(transaction.amount.toCurrencyString())
                    .font(.headline)
                    .foregroundColor(transaction.expense ? .red : .green)
                    .multilineTextAlignment(.trailing)
                if let description = transaction.description {
                    Text(description)
                }
                Spacer().frame(height: 10)
                LabeledField(label: "start", value: transaction.start.toLocaleString(), showDivider: true)
                LabeledField(label: "end", value: transaction.end?.toLocaleString(), showDivider: true)
                CategoryLineItem(transaction.categoryId)
                BudgetLineItem()
                UserLineItem(transaction.createdBy)
            }.padding()
        }
    }
    
    init(_ transaction: RecurringTransaction) {
        self.transaction = transaction
    }
}

#if DEBUG
struct RecurringTransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionDetailsView(MockRecurringTransactionRepository.transaction)
    }
}
#endif
