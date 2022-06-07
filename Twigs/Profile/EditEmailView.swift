//
//  EditEmailView.swift
//  Twigs
//
//  Created by William Brawner on 6/6/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI

struct EditEmailView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    @State var email: String
    @State var error: EmailError? = nil
    
    @ViewBuilder
    var body: some View {
        if case .saving(_) = dataStore.currentUser {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        } else {
            VStack(alignment: .leading, spacing: 4.0) {
                Form {
                    Section(content: {
                        TextField("prompt_email", text: $email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }, footer: {
                        if let error = self.error {
                            Text(LocalizedStringKey(error.rawValue))
                                .foregroundColor(.red)
                        }
                    })
                    Button("save", action: {
                        Task {
                            self.error = await dataStore.updateEmail(email)
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

struct EditEmailView_Previews: PreviewProvider {
    static var previews: some View {
        EditEmailView(email: "me@example.com")
            .environmentObject(DataStore(TwigsInMemoryCacheService()))
    }
}
