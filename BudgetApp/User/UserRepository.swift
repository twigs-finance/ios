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
    func getUser(id: Int) -> AnyPublisher<User, NetworkError>
    func searchUsers(withUsername: String) -> AnyPublisher<[User], NetworkError>
    func login(username: String, password: String) -> AnyPublisher<User, NetworkError>
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError>
}

class NetworkUserRepository: UserRepository {
    let apiService: BudgetApiService
    
    init(_ apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getUser(id: Int) -> AnyPublisher<User, NetworkError> {
        return apiService.getUser(id: id)
    }
    
    func searchUsers(withUsername: String) -> AnyPublisher<[User], NetworkError> {
        return apiService.searchUsers(query: withUsername)
    }
    
    func login(username: String, password: String) -> AnyPublisher<User, NetworkError> {
        return apiService.login(username: username, password: password)
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError> {
        return apiService.register(username: username, email: email, password: password)
    }
}

#if DEBUG

class MockUserRepository: UserRepository {
    func getUser(id: Int) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(.failure(NetworkError.unknown))
            .eraseToAnyPublisher()
    }
    
    func searchUsers(withUsername: String) -> AnyPublisher<[User], NetworkError> {
        return Result<[User], NetworkError>.Publisher(.failure(NetworkError.unknown))
            .eraseToAnyPublisher()
    }
    
    func login(username: String, password: String) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(.failure(NetworkError.unknown))
            .eraseToAnyPublisher()
    }
    
    func register(username: String, email: String, password: String) -> AnyPublisher<User, NetworkError> {
        return Result<User, NetworkError>.Publisher(.failure(NetworkError.unknown))
            .eraseToAnyPublisher()
    }
}

#endif
