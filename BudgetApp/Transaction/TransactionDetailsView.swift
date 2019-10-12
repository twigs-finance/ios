//
//  TransactionDetailsView.swift
//  Budget
//
//  Created by Billy Brawner on 10/1/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct TransactionDetailsView: View {
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch transactionDataStore.transaction {
        case .success(let transaction):
            return AnyView(VStack {
                Text(transaction.title)
            })
        case .failure(.loading):
            return AnyView(EmbeddedLoadingView())
        default:
            return AnyView(Text("transaction_details_error"))
        }
    }
    
    let transactionDataStore: TransactionDataStore
    init(_ dataStoreProvider: DataStoreProvider, transaction: Transaction) {
        let transactionDataStore = dataStoreProvider.transactionDataStore()
        transactionDataStore.getTransactions()
        self.transactionDataStore = transactionDataStore
    }
}

//struct TransactionDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionDetailsView()
//    }
//}
