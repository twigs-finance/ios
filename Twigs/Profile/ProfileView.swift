//
//  ProfileView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    let currentUser: User
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .frame(width: 100, height: 100, alignment: .center)
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 5)
            Text(currentUser.username)
            NavigationLink(destination: EmptyView()) {
                Text("change_password")
            }
            NavigationLink(destination: EmptyView()) {
                Text("change_email")
            }
            NavigationLink(destination: EmptyView()) {
                Text("delete_account")
                    .foregroundColor(.red)
            }
        }
    }
    
    let dataStoreProvider: DataStoreProvider
    init(_ dataStoreProvider: DataStoreProvider) {
        self.dataStoreProvider = dataStoreProvider
        self.currentUser = try! dataStoreProvider.authenticationDataStore().currentUser.get()
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(MockDataStoreProvider())
    }
}
#endif
