//
//  EditCategoryView.swift
//  Twigs
//
//  Created by William Brawner on 10/21/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI

struct CategoryFormSheet: View {
    @EnvironmentObject var categoryDataStore: CategoryDataStore
    @Binding var showSheet: Bool
    @State var title: String
    @State var description: String
    @State var amount: String
    @State var type: TransactionType
    @State var archived: Bool
    let categoryId: String
    let budgetId: String
    @State private var showingAlert = false
    
    var stateContent: AnyView {
        switch categoryDataStore.category {
        case .success(_):
            self.showSheet = false
            return AnyView(EmptyView())
        case .failure(.loading):
            return AnyView(EmbeddedLoadingView())
        default:
            return AnyView(Form {
                TextField("prompt_name", text: self.$title)
                    .textInputAutocapitalization(.words)
                TextField("prompt_description", text: self.$description)
                    .textInputAutocapitalization(.sentences      )
                TextField("prompt_amount", text: self.$amount)
                    .keyboardType(.decimalPad)
                Picker("prompt_type", selection: self.$type) {
                    ForEach(TransactionType.allCases) { type in
                        Text(type.localizedKey)
                    }
                }
                Toggle("prompt_archived", isOn: self.$archived)
                if categoryId != "" {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("delete")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented:$showingAlert) {
                        Alert(title: Text("confirm_delete"), message: Text("cannot_undo"), primaryButton: .destructive(Text("delete"), action: {
                            self.categoryDataStore.delete(categoryId)
                        }), secondaryButton: .cancel())
                    }
                } else {
                    EmptyView()
                }
            })
        }
    }
    
    @ViewBuilder
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarItems(
                    leading: Button("cancel") {
                        self.showSheet = false
                    },
                    trailing: Button("save") {
                        let amount = Double(self.amount) ?? 0.0
                        self.categoryDataStore.save(Category(
                            budgetId: self.budgetId,
                            id: self.categoryId,
                            title: self.title,
                            description: self.description,
                            amount: Int(amount * 100.0),
                            expense: self.type == TransactionType.expense,
                            archived: false
                        ))
                    })
        }.onDisappear {
            self.categoryDataStore.clearSelectedCategory()
        }
    }
    
    init(showSheet: Binding<Bool>, category: Category?, budgetId: String) {
        let initialCategory = category ?? Category(budgetId: budgetId, id: "", title: "", description: "", amount: 0, expense: true, archived: false)
        self._showSheet = showSheet
        self._title = State(initialValue: initialCategory.title)
        self._description = State(initialValue: initialCategory.description ?? "")
        self._amount = State(initialValue: initialCategory.amount.toDecimalString())
        let type: TransactionType
        if initialCategory.expense == false {
            type = .income
        } else {
            type = .expense
        }
        self._type = State(initialValue: type)
        self._archived = State(initialValue: initialCategory.archived)
        self.categoryId = initialCategory.id
        self.budgetId = budgetId
    }
}

#if DEBUG
struct CategoryFormSheet_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFormSheet(showSheet: .constant(true), category: nil, budgetId: "")
            .environmentObject(CategoryDataStore(MockCategoryRepository()))
    }
}
#endif
