//
//  Extensions.swift
//  Twigs
//
//  Created by Billy Brawner on 10/12/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

extension Int {
    func toDecimalString() -> String {
        return String(format: "%.2f", Double(self) / 100.0)
    }
    
    func toCurrencyString() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.numberStyle = .currency
        let doubleSelf = Double(self) / 100.0
        return currencyFormatter.string(from: NSNumber(value: doubleSelf)) ?? ""
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
