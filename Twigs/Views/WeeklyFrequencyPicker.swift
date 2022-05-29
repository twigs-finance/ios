//
//  WeeklyFrequencyPicker.swift
//  Twigs
//
//  Created by William Brawner on 5/27/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct WeeklyFrequencyPicker: View {
    @Binding var selection: Set<DayOfWeek>
    
    var body: some View {
        VStack {
            HStack {
                ForEach(DayOfWeek.allCases.slice(count: 4, page: 1)) { dayOfWeek in
                    Toggle(isOn: .constant(selection.contains(dayOfWeek))) {
                        Text(LocalizedStringKey(dayOfWeek.rawValue.lowercased()))
                            .lineLimit(1)
                            .onTapGesture {
                                if selection.contains(dayOfWeek) {
                                    selection.remove(dayOfWeek)
                                } else {
                                    selection.update(with: dayOfWeek)
                                }
                            }
                    }
                    .toggleStyle(.button)
                    .onSubmit {
                        print("Toggle selected for \(dayOfWeek)")
                    }
                }
            }
            HStack {
                ForEach(DayOfWeek.allCases.slice(count: 4, page: 2)) { dayOfWeek in
                    Toggle(isOn: .constant(selection.contains(dayOfWeek))) {
                        Text(LocalizedStringKey(dayOfWeek.rawValue.lowercased()))
                            .lineLimit(1)
                            .onTapGesture {
                                if selection.contains(dayOfWeek) {
                                    selection.remove(dayOfWeek)
                                } else {
                                    selection.update(with: dayOfWeek)
                                }
                            }
                    }
                    .toggleStyle(.button)
                }
            }
        }
    }
}

struct WeeklyFrequencyPicker_Previews: PreviewProvider {
    @State static var selection: Set<DayOfWeek> = Set()
    
    static var previews: some View {
        WeeklyFrequencyPicker(selection: $selection)
    }
}
