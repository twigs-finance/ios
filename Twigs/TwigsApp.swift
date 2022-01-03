//
//  TwigsApp.swift
//  Twigs
//
//  Created by William Brawner on 10/28/21.
//  Copyright © 2021 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

@main
struct TwigsApp: App {
    @AppStorage("BASE_URL") var baseUrl: String = ""
    @AppStorage("TOKEN") var token: String = ""
    @AppStorage("USER_ID") var userId: String = ""
    let apiService: TwigsInMemoryCacheService = TwigsInMemoryCacheService()
        
    var body: some Scene {
        WindowGroup {
            MainView(self.apiService, baseUrl: self.$baseUrl, token: self.$token, userId: self.$userId).onAppear {
                print("TwigsApp.onAppear")
                if self.baseUrl != "", self.token != "" {
                    self.apiService.baseUrl = self.baseUrl
                    self.apiService.token = self.token
                }
            }
        }
    }
}
