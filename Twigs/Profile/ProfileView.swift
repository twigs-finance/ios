//
//  ProfileView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct ProfileView: View {
    @EnvironmentObject var dataStore: DataStore
    var username: String {
        if case let .success(user) = self.dataStore.currentUser {
            return user.username
        } else {
            return ""
        }
    }
    var email: String {
        if case let .success(user) = self.dataStore.currentUser {
            return user.email ?? ""
        } else {
            return ""
        }
    }

    @ViewBuilder
    var body: some View {
        List {
            Section(content: {
                NavigationLink(
                    destination: EditUsernameView(username: username)
                        .navigationTitle("change_username")
                ) {
                    Text("change_username")
                }
//                NavigationLink(destination: EmptyView()) {
//                    Text("change_profile_picture")
//                }
            }, header: {
                HStack {
                    Spacer()
                    VStack(alignment: .center, spacing: 10.0) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100, alignment: .center)
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .shadow(radius: 4)
                        Spacer()
                        Text(username)
                    }
                    Spacer()
                }
            })
            Section {
                NavigationLink(
                    destination: EditPasswordView()
                            .navigationTitle("change_password")
                ) {
                    Text("change_password")
                }
                NavigationLink(
                    destination: EditEmailView(email: email)
                            .navigationTitle("change_email")
                ) {
                    Text("change_email")
                }
            }
            Section {
                Button("logout", action: {
                    // TODO: Show some dialog to confirm
                    dataStore.logout()
                })
            }
//            Section {
//                NavigationLink(destination: EmptyView()) {
//                    Text("delete_account")
//                        .foregroundColor(.red)
//                }
//            }
        }
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DataStore(TwigsInMemoryCacheService()))
    }
}
#endif
