//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine
import TwigsCore

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
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
        return nil
    }
    
    var body: some View {
        switch dataStore.currentUser {
        case .loading:
            ActivityIndicator(isAnimating: .constant(true), style: .medium)
        default:
            NavigationView {
                VStack {
                    Text("info_login")
                    if let error = self.error {
                        Text(LocalizedStringKey(error))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    }
                    TextField(LocalizedStringKey("prompt_server"), text: self.$dataStore.baseUrl)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.URL)
                        .disableAutocorrection(true)
                    TextField(LocalizedStringKey("prompt_username"), text: self.$username)
                        .autocapitalization(UITextAutocapitalizationType.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.username)
                        .disableAutocorrection(true)
                    SecureField(LocalizedStringKey("prompt_password"), text: self.$password, prompt: nil)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(UITextContentType.password)
                        .textContentType(.password)
                        .onSubmit {
                            Task {
                                await self.dataStore.login(username: self.username, password: self.password)
                            }
                        }
                    Button(action: {
                        Task {
                            await self.dataStore.login(username: self.username, password: self.password)
                        }
                    }, label: {
                        Text("action_login")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    HStack {
                        Text("info_register")
                        NavigationLink(
                            destination: RegistrationView(username: self.$username, password: self.$password)
                                .navigationTitle("action_register")
                                .onAppear {
                                    dataStore.clearUserError()
                                }
                                .onDisappear {
                                    dataStore.clearUserError()
                                }
                        ) {
                            Text("action_register")
                                .buttonStyle(DefaultButtonStyle())
                        }
                    }
                }.padding()
            }.navigationBarHidden(true)
                .navigationTitle("action_login")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // TODO: Write mock UserRepository with some test data
////        ContentView(userRepository: UserRepository())
//    }
//}
