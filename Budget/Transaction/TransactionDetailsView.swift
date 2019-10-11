//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TransactionDetailsView: View {
    @State var title: String = ""
    @State var description: String? = nil
    @State var date: Date = Date()
    @State var amount: Int = 0
    @State var category: Category? = nil
    @State var expense: Bool = true
    @State var createdBy: User? = nil
    @State var budget: Budget? = nil

    var body: some View {
        List {
            TextField("prompt_title", text: self.$title)
//            DatePicker(
        }
    }
    
    init(_ dataStoreProvider: DataStoreProvider, transaction: Transaction) {
//        self.title = transaction.title
//        self.description = transaction.description
//        self.date = transaction.date
//        self.amount = transaction.amount
//        self.category = transaction.category
//        self.expense = transaction.expense
//        self.createdBy = transaction.createdBy
//        self.budget = transaction.budget
    }
}

//struct TransactionDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionDetailsView()
//    }
//}
