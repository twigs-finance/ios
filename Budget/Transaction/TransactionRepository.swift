//
//  TransactionRepository.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

protocol TransactionRepository {
    func getUser(id: UInt) throws -> User
    func searchUsers(byName: String) throws -> [User]
    func newUser(user: User) throws -> User
    func updateUser(user: User) throws -> User
    func deleteUser(user: User) throws -> Void
}

