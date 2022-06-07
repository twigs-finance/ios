//
//  EditUsernameView.swift
//  Twigs
//
//  Created by William Brawner on 6/4/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct EditUsernameView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State var username: String
    @State var error: UsernameError? = nil
    
    @ViewBuilder
    var body: some View {
        if case .saving(_) = dataStore.currentUser {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        } else {
            VStack(alignment: .leading, spacing: 4.0) {
                if case .unavailable = self.error {
                    Text("username_unavailable")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                Form {
                    Section("prompt_username") {
                        TextField("prompt_username", text: $username)
                            .textContentType(.username)
                    }
                    Button("save", action: {
                        Task {
                            self.error = await dataStore.updateUsername(username)
                            if self.error == nil {
                                dismiss()
                            }
                        }
                    })
                }
            }
        }
    }
}

struct EditUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        EditUsernameView(username: "username")
            .environmentObject(DataStore(TwigsInMemoryCacheService()))
    }
}
