//
//  TextFieldV04.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 30/10/2023.
//

import SwiftUI

struct TextFieldV04: View {
        @Binding var value: Int
           var placeholder: String = ""
           var body: some View {
               TextField(placeholder, text: Binding(
                   get: { String(value) },
                   set: {
                       if let intValue = Int($0) {
                           self.value = intValue
                       }
                   }
               ))
               .keyboardType(.numberPad)
           }
       }

struct TextFieldV04_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldV04(value: .constant(0), placeholder: "")
    }
}
