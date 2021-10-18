//
//  UserDataStore.swift
//  Twigs
//
//  Created by Billy Brawner on 10/12/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class UserDataStore: ObservableObject {
    private var currentRequest: AnyCancellable? = nil
    @Published var user: Result<User, NetworkError> = .failure(.loading)

    func getUser(_ id: String) {
        self.user = .failure(.loading)
        
        self.currentRequest = userRepository.getUser(id)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { (status) in
            switch status {
            case .finished:
                self.currentRequest = nil
                return
            case .failure(let error):
                self.user = .failure(error)
                return
            }
        }, receiveValue: { (user) in
            self.user = .success(user)
        })

    }
    
    private let userRepository: UserRepository
    
    init(_ userRepository: UserRepository) {
        self.userRepository = userRepository
    }
}
