//
//  UserData.swift
//  Budget
//
//  Created by Billy Brawner on 9/26/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject {
    var currentUser: User? = nil
    let userRepository: UserRepository
    private var subscriptions = Set<AnyCancellable>()
    @Published public var userStatus: UserStatus = UserStatus.unauthenticated
    
    init(repository: UserRepository) {
        self.userRepository = repository
    }
    
    func login(username: String, password: String) {
        self.userStatus = UserStatus.authenticating
        userRepository.login(username: username, password: password)
        .sink(receiveCompletion: { (completion) in
            // TODO: What to do here?
            if self.userStatus == UserStatus.authenticating {
                self.userStatus = UserStatus.failedAuthentication
            }
        }, receiveValue: { user in
            print ("User ID?: \(String(describing: user.id))")
            self.currentUser = user
            if self.userStatus == UserStatus.authenticating {
                self.userStatus = UserStatus.authenticated
            }
            // TODO: Continue to next view on success
        })
        .store(in: &subscriptions)

    }
}

enum UserStatus {
    case unauthenticated
    case authenticating
    case failedAuthentication
    case authenticated
}
