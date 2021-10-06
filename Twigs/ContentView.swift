//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authenticationDataStore: AuthenticationDataStore
    
    @ViewBuilder
    var body: some View {
        if showLogin() {
            LoginView()
        } else {
            BudgetListsView()
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
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
