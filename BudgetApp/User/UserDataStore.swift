//
//  UserDataStore.swift
//  BudgetApp
//
//  Created by Billy Brawner on 10/12/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class UserDataStore: ObservableObject {
    
    var user: Result<User, NetworkError> = .failure(.loading) {
        didSet {
            self.objectWillChange.send()
        }
    }

    func getUser(_ id: Int) {
        self.user = .failure(.loading)
        
        _ = userRepository.getUser(id)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { (status) in
            switch status {
            case .finished:
                return
            case .failure(let error):
                self.user = .failure(error)
                return
            }
        }, receiveValue: { (user) in
            self.user = .success(user)
        })

    }
    
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // Needed since the default implementation is currently broken
    let objectWillChange = ObservableObjectPublisher()
    private let userRepository: UserRepository
}
