//
//  TextFieldV03.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 30/10/2023.
//
//
import SwiftUI

struct TextFieldV03: View {
    @Binding var value: Int
    var placeholder: String = ""

    var body: some View {
        TextField(placeholder, text: Binding(
            get: { String(value) },
            set: {
                if let intValue = Int($0.prefix(5)), intValue >= 0 {
                    self.value = intValue
                }
            }
        ))
        .keyboardType(.numberPad)
        .onAppear {
            self.value = 0
        }
    }
}
