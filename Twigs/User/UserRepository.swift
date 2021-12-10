//
//  UserRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

protocol UserRepository {
    func setToken(_ token: String)
    func getUser(_ id: String) -> AnyPublisher<User, NetworkError>
    func searchUsers(_ withUsername: String) -> AnyPublisher<[User], NetworkError>
    func setServer(_ server: String)
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, NetworkError>
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError>
}

#if DEBUG

class MockUserRepository: UserRepository {
    static let loginResponse = LoginResponse(token: "token", expiration: "2020-01-01T12:00:00Z", userId: "0")
    static let user = User(id: "0", username: "root", email: "root@localhost", avatar: nil)
    static var token: String? = nil

    func setToken(_ token: String) {
        MockUserRepository.token = token
    }
    
    func getUser(_ id: String) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(MockUserRepository.user)
            .eraseToAnyPublisher()
    }
    
    func searchUsers(_ withUsername: String) -> AnyPublisher<[User], NetworkError> {
        return Result<[User], NetworkError>.Publisher([MockUserRepository.user])
            .eraseToAnyPublisher()
    }
    
    func setServer(_ server: String) {
    }
    
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, NetworkError> {
        return Result<LoginResponse, NetworkError>.Publisher(MockUserRepository.loginResponse)
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(MockUserRepository.user)
            .eraseToAnyPublisher()
    }
}

#endif
