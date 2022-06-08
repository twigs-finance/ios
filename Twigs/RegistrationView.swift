//
//  RegistrationView.swift
//  Budget
//
//  Created by Billy Brawner on 10/3/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct RegistrationView: View {
    @Binding var username: String
    @State var email: String = ""
    @Binding var password: String
    @State var confirmedPassword: String = ""
    @EnvironmentObject var dataStore: DataStore
    var error: String? {
        if case let .error(error as NetworkError, _) = dataStore.currentUser {
            switch error {
            case .badRequest(let reason):
                if reason == nil || reason?.isEmpty == true {
                    return "unknown_error"
                }
                return reason
            case .server:
                return "server_error"
            case .invalidUrl, .notFound:
                return "server_invalid"
            case .unauthorized:
                return "credentials_invalid"
            default:
                return "unknown_error"
            }
        }
        if case let .error(error as UsernameError, _) = dataStore.currentUser {
            return error.rawValue
        }
        if case let .error(error as EmailError, _) = dataStore.currentUser {
            return error.rawValue
        }
        if case let .error(error as PasswordError, _) = dataStore.currentUser {
            return error.rawValue
        }
        return nil
    }

    var body: some View {
        switch dataStore.currentUser {
        case .loading:
            ActivityIndicator(isAnimating: .constant(true), style: .medium)
        default:
            VStack {
                if let error = self.error {
                    Text(LocalizedStringKey(error))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
                TextField(LocalizedStringKey("prompt_server"), text: self.$dataStore.baseUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.URL)
                TextField("prompt_username", text: self.$username)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(UITextContentType.username)
                TextField("prompt_email", text: self.$email)
                    .textContentType(UITextContentType.emailAddress)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("prompt_password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(UITextContentType.newPassword)
                SecureField("prompt_confirm_password", text: self.$confirmedPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(UITextContentType.newPassword)
                    .onSubmit {
                        Task {
                            await self.dataStore.register(
                                username: self.username,
                                email: self.email,
                                password: self.password,
                                confirmPassword: self.confirmedPassword
                            )
                        }
                    }
                Button(action: {
                    Task {
                        await self.dataStore.register(
                            username: self.username,
                            email: self.email,
                            password: self.password,
                            confirmPassword: self.confirmedPassword
                        )
                    }
                }, label: {
                    Text("action_register")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
            }.padding()
        }
    }
}

//struct RegistrationView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegistrationView()
//    }
//}
