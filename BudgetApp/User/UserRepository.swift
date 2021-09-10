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
    func getUser(_ id: String) -> AnyPublisher<User, NetworkError>
    func searchUsers(_ withUsername: String) -> AnyPublisher<[User], NetworkError>
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, NetworkError>
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError>
}

class NetworkUserRepository: UserRepository {
    let apiService: BudgetAppApiService
    
    init(_ apiService: BudgetAppApiService) {
        self.apiService = apiService
    }
    
    func getUser(_ id: String) -> AnyPublisher<User, NetworkError> {
        return apiService.getUser(id: id)
    }
    
    func searchUsers(_ withUsername: String) -> AnyPublisher<[User], NetworkError> {
        return apiService.searchUsers(query: withUsername)
    }
    
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, NetworkError> {
        return apiService.login(username: username, password: password)
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError> {
        return apiService.register(username: username, email: email, password: password)
    }
}

#if DEBUG

class MockUserRepository: UserRepository {
    static let loginResponse = LoginResponse(token: "token", expiration: "2020-01-01T12:00:00Z", userId: "0")
    static let user = User(id: "0", username: "root", email: "root@localhost", avatar: nil)
    
    func getUser(_ id: String) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(MockUserRepository.user)
            .eraseToAnyPublisher()
    }
    
    func searchUsers(_ withUsername: String) -> AnyPublisher<[User], NetworkError> {
        return Result<[User], NetworkError>.Publisher([MockUserRepository.user])
            .eraseToAnyPublisher()
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
