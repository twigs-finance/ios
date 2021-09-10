//
//  User.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    let id: String
    let username: String
    let email: String?
    let avatar: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let expiration: String
    let userId: String
}

struct RegistrationRequest: Codable {
    let username: String
    let email: String
    let password: String
}
