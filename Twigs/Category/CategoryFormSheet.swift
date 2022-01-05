//
//  EditCategoryView.swift
//  Twigs
//
//  Created by William Brawner on 10/21/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct CategoryFormSheet: View {
    @EnvironmentObject var categoryList: CategoryListDataStore
    @ObservedObject var categoryForm: CategoryForm
    @State private var showingAlert = false
    
    @ViewBuilder
    var stateContent: some View {
        switch categoryList.category {
        case .success(_):
            EmptyView()
        case .saving(_):
            EmbeddedLoadingView()
        default:
            Form {
                TextField("prompt_name", text: $categoryForm.title)
                    .textInputAutocapitalization(.words)
                TextField("prompt_description", text: $categoryForm.description)
                    .textInputAutocapitalization(.sentences      )
                TextField("prompt_amount", text: $categoryForm.amount)
                    .keyboardType(.decimalPad)
                Picker("prompt_type", selection: $categoryForm.type) {
                    ForEach(TransactionType.allCases) { type in
                        Text(type.localizedKey)
                    }
                }
                Toggle("prompt_archived", isOn: $categoryForm.archived)
                if categoryForm.showDelete {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("delete")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("confirm_delete"), message: Text("cannot_undo"), primaryButton: .destructive(Text("delete"), action: {
                            Task {
                                await self.categoryForm.delete()
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
        NavigationView {
            stateContent
                .navigationBarItems(
                    leading: Button("cancel") {
                        categoryList.cancelEdit()
                    },
                    trailing: Button("save") {
                        Task {
                            await self.categoryForm.save()
                        }
                    })
        }
    }
}

//#if DEBUG
//struct CategoryFormSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryFormSheet(categoryForm: CategoryForm())
//    }
//}
//#endif
