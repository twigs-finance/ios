//
//  MonthlyFrequencyPicker.swift
//  Twigs
//
//  Created by William Brawner on 5/27/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct MonthlyFrequencyPicker: UIViewRepresentable {
    @Binding var dayOfMonth: DayOfMonth
    @State var dayOfWeek: Int
    @State var intDay: Int
    @State var ordinalDay: Int
    
    init(dayOfMonth: Binding<DayOfMonth>) {
        self._dayOfMonth = dayOfMonth
        if case let .fixed(intDay) = dayOfMonth.wrappedValue {
            self.intDay = intDay - 1
            self.ordinalDay = 0
            self.dayOfWeek = 0
        } else if case let .ordinal(ordinalDay, dayOfWeek) = dayOfMonth.wrappedValue {
            self.intDay = 0
            self.ordinalDay = Ordinal.allCases.firstIndex(of: ordinalDay)!
            self.dayOfWeek = DayOfWeek.allCases.firstIndex(of: dayOfWeek)!
        } else {
            self.intDay = 0
            self.dayOfWeek = 0
            self.ordinalDay = 0
        }
    }
    
    func makeCoordinator() -> MonthlyFrequencyPicker.Coordinator {
        Coordinator(self, selectedOrdinal: $ordinalDay, selectedDay: $intDay, selectedDayOfWeek: $dayOfWeek)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MonthlyFrequencyPicker>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<MonthlyFrequencyPicker>) {
        view.selectRow(ordinalDay, inComponent: 0, animated: false)
        let component2Selection = ordinalDay == 0 ? intDay : dayOfWeek
        view.selectRow(component2Selection, inComponent: 1, animated: true)
        view.reloadComponent(1)
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let ordinals = Ordinal.allCases.map {
            $0.rawValue.lowercased()
        }
        
        var parent: MonthlyFrequencyPicker
        @Binding var selectedOrdinal: Int {
            didSet {
                // This is a workaround for the pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) function not getting the correct values for the selectedOrdinal
                ordinal = self.selectedOrdinal
            }
        }
        @Binding var selectedDay: Int
        @Binding var selectedDayOfWeek: Int
        
        private var ordinal = 0
        
        init(_ pickerView: MonthlyFrequencyPicker, selectedOrdinal: Binding<Int>, selectedDay: Binding<Int>, selectedDayOfWeek: Binding<Int>) {
            self.parent = pickerView
            self._selectedOrdinal = selectedOrdinal
            self._selectedDay = selectedDay
            self._selectedDayOfWeek = selectedDayOfWeek
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return ordinals.count
            }
            if ordinal == 0 {
                return 31
            } else {
                return 7
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return NSLocalizedString(ordinals[row], comment: "")
            }
            
            if ordinal == 0 {
                return String(row + 1)
            } else {
                return NSLocalizedString(DayOfWeek.allCases[row].rawValue, comment: "")
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                selectedOrdinal = row
                return
            }
            if ordinal == 0 {
                selectedDay = row
            } else {
                selectedDayOfWeek = row
            }
        }
    }
}

struct MonthlyFrequencyPicker_Previews: PreviewProvider {
    @State static var dayOfMonth: DayOfMonth = .fixed(1)
    
    static var previews: some View {
        MonthlyFrequencyPicker(dayOfMonth: $dayOfMonth)
    }
}
