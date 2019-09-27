//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        LoadingView(
            isShowing: .constant(userData.userStatus == UserStatus.authenticating),
            loadingText: "loading_login"
        ) {
            VStack {
                Text("info_login")
                TextField("prompt_username", text: self.$username)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("prompt_password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("action_login", action: {
                    print("Username: \(self.username), Password: \(self.password)")
                    self.userData.login(username: self.username, password: self.password)
                }).buttonStyle(DefaultButtonStyle())
            }.padding()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // TODO: Write mock UserRepository with some test data
////        ContentView(userRepository: UserRepository())
//    }
//}
