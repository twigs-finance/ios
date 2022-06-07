//
//  UserRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine
import TwigsCore

#if DEBUG
class MockUserRepository: UserRepository {
    static let loginResponse = LoginResponse(token: "token", expiration: "2020-01-01T12:00:00Z", userId: "0")
    static let currentUser = User(id: "0", username: "root", email: "root@localhost", password: nil, avatar: nil)
    static var token: String? = nil

    func setToken(_ token: String) {
        MockUserRepository.token = token
    }
    
    func getUser(_ id: String) async throws -> User {
        return MockUserRepository.currentUser
    }
    
    func searchUsers(_ withUsername: String) async throws -> [User] {
        return [MockUserRepository.currentUser]
    }
    
    func setServer(_ server: String) {
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        return MockUserRepository.loginResponse
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        return MockUserRepository.currentUser
    }
}

#endif
