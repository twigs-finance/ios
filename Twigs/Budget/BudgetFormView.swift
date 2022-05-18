//
//  BudgetFormView.swift
//  Twigs
//
//  Created by William Brawner on 5/18/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct BudgetFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var title = ""
    @State private var description = ""
    @State private var showingAlert = false
    private var budgetId: String {
        get {
            if case let .editing(budget) = dataStore.budget {
                return budget.id
            } else {
                return ""
            }
        }
    }
    
    @ViewBuilder
    var stateContent: some View {
        switch dataStore.category {
        case .success(_):
            EmptyView()
        case .saving(_):
            EmbeddedLoadingView()
        default:
            Form {
                TextField("prompt_name", text: $title)
                    .textInputAutocapitalization(.words)
                TextField("prompt_description", text: $description)
                    .textInputAutocapitalization(.sentences      )
                if case let .editing(budget) = dataStore.budget, budget.id != "" {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("delete")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("confirm_delete"), message: Text("cannot_undo"), primaryButton: .destructive(Text("delete"), action: {
                            Task {
                                await self.dataStore.deleteBudget()
                            }
                        }), secondaryButton: .cancel())
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    var body: some View {
        stateContent
            .navigationBarItems(
                trailing: Button("save") {
                    Task {
                        await self.dataStore.save(Budget(id: budgetId, name: title, description: description, currencyCode: nil))
                    }
                })
    }
}

struct BudgetFormView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetFormView()
    }
}
