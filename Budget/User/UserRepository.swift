//
//  UserRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

protocol UserRepository {
    var currentUser: User? { get }
    func getUser(id: UInt) throws -> User
    func searchUsers(withUsername: String) throws -> [User]
    func login(username: String, password: String, completionHandler: @escaping (User?, Error?) -> Void) throws
}

class NetworkUserRepository : UserRepository {
    var currentUser: User?
    let apiService: BudgetApiService
    
    init(apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getUser(id: UInt) throws -> User {
        if (currentUser?.id == id) {
            return currentUser!
        }
        
        return try! apiService.getUser(id: id)
    }
    
    func searchUsers(withUsername: String) throws -> [User] {
        return []
    }
    
    func login(username: String, password: String, completionHandler: @escaping (User?, Error?) -> Void) throws {
        try apiService.login(username: username, password: password, completionHandler: completionHandler)
    }
}
