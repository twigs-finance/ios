//
//  MainView.swift
//  Twigs
//
//  Created by William Brawner on 12/30/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct MainView: View {
    @StateObject var dataStore: DataStore
    let apiService: TwigsApiService
    
    init(_ apiService: TwigsApiService) {
        self.apiService = apiService
        self._dataStore = StateObject(wrappedValue: DataStore(apiService, errorReporter: LoggingErrorReporter()))
    }
    
    @ViewBuilder
    var mainView: some View {
        if UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .pad {
            SidebarBudgetView()
        } else {
            TabbedBudgetView()
        }
    }
    
    var body: some View {
        mainView
            .environmentObject(dataStore)
            .onAppear {
                Task {
                    await self.dataStore.loadProfile()
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(TwigsInMemoryCacheService())
    }
}
