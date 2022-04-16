//
//  ProgressView.swift
//  Twigs
//
//  Created by Billy Brawner on 10/20/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    var value: Float
    var maxValue: Float = 100.0
    var progressTintColor: Color = .blue
    var progressBarHeight: Float = 20
    var progressBarCornerRadius: Float = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.1)
                Rectangle()
                    .frame(width: getProgressBarWidth(geometry: geometry))
                    .opacity(0.5)
                    .background(self.progressTintColor)
                    .animation(.default)
            }.frame(height: CGFloat(self.progressBarHeight))
                .cornerRadius(CGFloat(self.progressBarCornerRadius))
        }
    }
    
    private func getProgressBarWidth(geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        return max(0, frame.size.width * min(CGFloat(value / maxValue), CGFloat(1)))
    }
}


struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("0%")
            ProgressView(value: 1.0, maxValue: 0.0, progressTintColor: .red)
            Text("25%")
            ProgressView(value: 1.0, maxValue: 4.0, progressTintColor: .green)
            Text("50%")
            ProgressView(value: 1.0, maxValue: 2.0, progressTintColor: .blue)
            Text("66%")
            ProgressView(value: 2.0, maxValue: 3.0, progressTintColor: .orange)
            Text("150%")
            ProgressView(value: 150.0, maxValue: 100.0, progressTintColor: .purple)
        }.padding(50)
    }
}
