//
//  RegistrationView.swift
//  Budget
//
//  Created by Billy Brawner on 10/3/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct RegistrationView: View {
    @Binding var server: String
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @EnvironmentObject var dataStore: AuthenticationDataStore
    
    var body: some View {
        VStack {
            TextField(LocalizedStringKey("prompt_server"), text: self.$server)
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
            Button("action_register", action: {
                Task {
                    try await self.dataStore.register(
                        server: self.server,
                        username: self.username,
                        email: self.email,
                        password: self.password,
                        confirmPassword: self.confirmedPassword
                    )
                }
            }).buttonStyle(DefaultButtonStyle())
        }.padding()
    }
}

//struct RegistrationView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegistrationView()
//    }
//}
