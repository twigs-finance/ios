//
//  ContentView.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var username: String = ""
    @State var password: String = ""
    let userRepository: UserRepository
    
    var body: some View {
        VStack {
            Text("info_login")
            TextField("prompt_username", text: $username)
                .autocapitalization(UITextAutocapitalizationType.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("prompt_password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("action_login", action: {
                print("Username: \(self.username), Password: \(self.password)")
                DispatchQueue.global(qos: .background).async {
                    // TODO: show loader, do login request, etc
                    do {
                        try self.userRepository.login(
                            username: self.username,
                            password: self.password,
                            completionHandler: { user, error in
                                print("User ID?: \(String(describing: user?.id))")
                            }
                        )
                    } catch {
                        print("Unable to log in")
                    }
                }
            })
                .buttonStyle(DefaultButtonStyle())
        }
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // TODO: Write mock UserRepository with some test data
////        ContentView(userRepository: UserRepository())
//    }
//}
