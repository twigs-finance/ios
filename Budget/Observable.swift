//
//  Observable.swift
//  Budget
//
//  Created by Billy Brawner on 10/11/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import Combine

class Observable<T>: ObservableObject, Identifiable {
    let id = UUID()
    let objectWillChange = ObservableObjectPublisher()
    let publisher = PassthroughSubject<T, Never>()
    var value: T {
        didSet {
            objectWillChange.send()
            publisher.send(value)
        }
    }

    init(_ initValue: T) { self.value = initValue }
}
