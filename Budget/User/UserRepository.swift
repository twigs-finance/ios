//
//  UserRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class UserRepository {
    let apiService: BudgetApiService

    init(apiService: BudgetApiService) {
        self.apiService = apiService
    }
    
    func getUser(id: Int) -> Future<User, NetworkError> {
        return apiService.getUser(id: id)
    }
    
    func searchUsers(withUsername: String) -> Future<[User], NetworkError> {
        return apiService.searchUsers(query: withUsername)
    }
    
    func login(username: String, password: String) -> Future<User, NetworkError> {
        return apiService.login(username: username, password: password)
    }
}
