//
//  UserDataStore.swift
//  Twigs
//
//  Created by Billy Brawner on 10/12/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

class UserDataStore: AsyncObservableObject {
    @Published var user: AsyncData<User> = .empty

    func getUser(_ id: String) async {
        do {
            let user = try await self.userRepository.getUser(id)
            self.user = .success(user)
        } catch {
            self.user = .error(error)
        }
    }
    
    private let userRepository: UserRepository
    
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }
}
