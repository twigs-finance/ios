//
//  Extensions.swift
//  Twigs
//
//  Created by Billy Brawner on 10/12/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

extension Date {
    static var firstOfMonth: Date {
        get {
            return Calendar.current.dateComponents([.calendar, .year,.month], from: Date()).date!
        }
    }
    
    static let localeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current)
        return dateFormatter
    }()
    
    func toLocaleString() -> String {
        return Date.localeDateFormatter.string(from: self)
    }
}

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

extension Array where Element: Identifiable {
    mutating func remove(byId id: Element.ID) -> Element? {
        if let index = firstIndex(where: { $0.id == id} ) {
            return remove(at: index)
        }
        return nil
    }
    
    func filter(withoutId id: Element.ID) -> [Element] {
        var updated = self
        _ = updated.remove(byId: id)
        return updated
    }
}
