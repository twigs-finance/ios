//
//  YearlyFrequencyPicker.swift
//  Twigs
//
//  Created by William Brawner on 5/27/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//

import SwiftUI
import TwigsCore

struct YearlyFrequencyPicker: UIViewRepresentable {
    @Binding var dayOfYear: DayOfYear
    var selectedMonth: Int {
        didSet {
            selectedDay = min(self.selectedDay, DayOfYear.maxDays(inMonth: self.selectedMonth + 1) - 1)
        }
    }
    var selectedDay: Int {
        didSet {
            print("Upading selectedDay")
            if let dayOfYear = DayOfYear(month: selectedMonth + 1, day: selectedDay + 1) {
                self.dayOfYear = dayOfYear
            } else {
                print("WARNING: Failed to set dayOfYear with \(selectedMonth) and \(selectedDay)")
            }
        }
    }
    
    init(dayOfYear: Binding<DayOfYear>) {
        self._dayOfYear = dayOfYear
        self.selectedMonth = dayOfYear.wrappedValue.month - 1
        self.selectedDay = dayOfYear.wrappedValue.day - 1
    }
    
    func makeCoordinator() -> YearlyFrequencyPicker.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<YearlyFrequencyPicker>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<YearlyFrequencyPicker>) {
        view.selectRow(selectedMonth, inComponent: 0, animated: false)
        view.selectRow(selectedDay, inComponent: 1, animated: true)
        view.reloadComponent(1)
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let months = [
            "january",
            "february",
            "march",
            "april",
            "may",
            "june",
            "july",
            "august",
            "september",
            "october",
            "november",
            "december"
        ]

        var parent: YearlyFrequencyPicker
        private var month = 0

        init(_ pickerView: YearlyFrequencyPicker) {
            self.parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return months.count
            }
            return DayOfYear.maxDays(inMonth: month + 1)
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return NSLocalizedString(months[row], comment: "")
            }
            
            return String(row + 1)
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.selectedMonth = row
                month = row
            } else {
                parent.selectedDay = row
                print("update selectedDay")
            }
        }
    }
}

struct YearlyFrequencyPicker_Previews: PreviewProvider {
    @State static var dayOfYear: DayOfYear = (DayOfYear(month: 1, day: 1)!)
    
    static var previews: some View {
        YearlyFrequencyPicker(dayOfYear: $dayOfYear)
    }
}
