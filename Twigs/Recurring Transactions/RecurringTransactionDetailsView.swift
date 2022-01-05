//
//  RecurringTransactionDetailsView.swift
//  Twigs
//
//  Created by William Brawner on 12/7/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct RecurringTransactionDetailsView: View {
    @EnvironmentObject var dataStore: RecurringTransactionDataStore
    
    var body: some View {
        if let transaction = dataStore.selectedTransaction {
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
                    Text(transaction.frequency.naturalDescription)
                    Spacer().frame(height: 10)
                    LabeledField(label: "start", value: transaction.start.toLocaleString(), loading: .constant(false), showDivider: true)
                    LabeledField(label: "end", value: transaction.end?.toLocaleString(), loading: .constant(false), showDivider: true)
//                    CategoryLineItem()
//                    BudgetLineItem()
//                    UserLineItem()
                }.padding()
            }
        }
    }
}

#if DEBUG
struct RecurringTransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringTransactionDetailsView()
    }
}
#endif
