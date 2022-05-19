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
    @State private var title: String
    @State private var description: String
    @State private var showingAlert = false
    private var budgetId: String
    
    @ViewBuilder
    var stateContent: some View {
        switch dataStore.budget {
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
    
    init(_ budget: Budget? = nil) {
        self.budgetId = budget?.id ?? ""
        self.title = budget?.name ?? ""
        self.description = budget?.description ?? ""
    }
}

struct BudgetFormView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetFormView()
    }
}
