//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State var server: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var dataStore: AuthenticationDataStore
    var loading: Bool {
        switch dataStore.user {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        LoadingView(
            isShowing: .constant(loading),
            loadingText: "loading_login"
        ) {
            NavigationView {
                VStack {
                    Text("info_login")
                    TextField(LocalizedStringKey("prompt_server"), text: self.$server)
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
                    Button("action_login", action: {
                        Task {
                            await self.dataStore.login(server: self.server, username: self.username, password: self.password)
                        }
                    }).buttonStyle(DefaultButtonStyle())
                    Spacer()
                    Text("info_register")
                    NavigationLink(destination: RegistrationView(server: self.$server)) {
                        Text("action_register")
                            .buttonStyle(DefaultButtonStyle())
                    }
                }.padding()
            }.navigationBarHidden(true)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // TODO: Write mock UserRepository with some test data
////        ContentView(userRepository: UserRepository())
//    }
//}
