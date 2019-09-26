//
//  User.swift
//  Budget
//
//  Created by Billy Brawner on 9/25/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: UInt? = nil
    let username: String
    let email: String? = nil
    let avatar: String? = nil
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}
