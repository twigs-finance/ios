//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authenticationDataStore: AuthenticationDataStore
    
    @ViewBuilder
    var body: some View {
        if showLogin() {
            LoginView(authenticationDataStore)
        } else {
            TabbedBudgetView(authenticationDataStore, dataStoreProvider: dataStoreProvider)
        }
    }
    
    func showLogin() -> Bool {
        switch authenticationDataStore.currentUser {
        case .failure:
            return true
        default:
            return false
        }
    }
    
    private let dataStoreProvider: DataStoreProvider
    
    init (_ dataStoreProvider: DataStoreProvider) {
        self.dataStoreProvider = dataStoreProvider
        self.authenticationDataStore = dataStoreProvider.authenticationDataStore()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
