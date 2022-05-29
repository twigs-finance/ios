//
//  MultiPicker.swift
//  Twigs
//
//  Created by William Brawner on 5/20/22.
//  Copyright © 2022 William Brawner. All rights reserved.
//  Adapted from https://stackoverflow.com/a/58664469

import SwiftUI

struct MultiPicker: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]

    func makeCoordinator() -> MultiPicker.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MultiPicker>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)

        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<MultiPicker>) {
        for i in 0...(self.selections.count - 1) {
            view.selectRow(self.selections[i], inComponent: i, animated: false)
        }
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: MultiPicker

        init(_ pickerView: MultiPicker) {
            self.parent = pickerView
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.data[component][row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections[component] = row
        }
    }
}

struct MultiPicker_Previews: PreviewProvider {
    @State static var selections: [Int] = [0, 0]
    
    static var previews: some View {
        MultiPicker(data: [["a", "b", "c"], ["one", "two", "three"]], selections: $selections)
    }
}
