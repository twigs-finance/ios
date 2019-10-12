//
//  Budget.swift
//  Budget
//
//  Created by Billy Brawner on 9/30/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation

struct Budget: Identifiable, Hashable, Codable {
    let id: Int?
    let name: String
    let description: String?
    let users: [User]
}
