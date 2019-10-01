//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/29/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userData: UserDataStore
    
    var body: some View {
        Group {
            if showLogin() {
                LoginView(userData)
            } else {
                TabbedBudgetView(userData, budgetRepository: budgetRepository)
            }
        }
    }
    
    func showLogin() -> Bool {
        switch userData.currentUser {
        case .failure:
            return true
        default:
            return false
        }
    }
    
    private let budgetRepository: BudgetRepository
    
    init (_ userData: UserDataStore, budgetRepository: BudgetRepository) {
        self.userData = userData
        self.budgetRepository = budgetRepository
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
