//
//  CategoriesView.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct CategoryListView: View {
    @ObservedObject var categoryDataStore: CategoryDataStore
    
    var body: some View {
        stateContent
    }
    
    var stateContent: AnyView {
        switch self.categoryDataStore.categories {
        case .success(let categories):
            return AnyView(
                Section {
                    List(categories) { category in
                        CategoryListItemView(self.dataStoreProvider, category: category)
                    }
                }
            )
        case .failure(.loading):
            return AnyView(VStack {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            })
        default:
            // TODO: Handle each network failure type
            return AnyView(Text("budgets_load_failure"))
        }
    }
    
    private let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider, budget: Budget) {
        self.dataStoreProvider = dataStoreProvider
        let categoryDataStore = dataStoreProvider.categoryDataStore()
        categoryDataStore.getCategories(budgetId: budget.id!)
        self.categoryDataStore = categoryDataStore
    }
}

struct CategoryListItemView: View {
    var category: Category
    let dataStoreProvider: DataStoreProvider
    
    var body: some View {
        NavigationLink(
            destination: TransactionListView(self.dataStoreProvider, category: category)
                .navigationBarTitle(category.title)
        ) {
            VStack(alignment: .leading) {
                Text(verbatim: category.title)
                if category.description?.isEmpty == false {
                    Text(verbatim: category.description!)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    init (_ dataStoreProvider: DataStoreProvider, category: Category) {
        self.dataStoreProvider = dataStoreProvider
        self.category = category
    }
}


//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
