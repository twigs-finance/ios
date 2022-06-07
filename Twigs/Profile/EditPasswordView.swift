//
//  EditPasswordView.swift
//  Twigs
//
//  Created by William Brawner on 6/6/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI

struct EditPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStore
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var error: PasswordError? = nil
    
    @ViewBuilder
    var body: some View {
        if case .saving(_) = dataStore.currentUser {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        } else {
            VStack(alignment: .leading, spacing: 4.0) {
                if case .notMatching = self.error {
                    Text("passwords_must_match")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                Form {
                    Section {
                        SecureField("prompt_password", text: $password)
                            .textContentType(.newPassword)
                        SecureField("prompt_confirm_password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                    Button("save", action: {
                        Task {
                            self.error = await dataStore.updatePassword(password, confirmPassword: confirmPassword)
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

struct EditPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EditPasswordView()
            .environmentObject(DataStore(TwigsInMemoryCacheService()))
    }
}
