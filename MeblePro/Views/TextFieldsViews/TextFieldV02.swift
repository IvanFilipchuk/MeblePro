//
//  TextFieldV02.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct TextFieldV02: View {
    @Binding var value: String
    var placeholder: String = ""
    var body: some View {
             TextField(placeholder, text: $value, axis: .vertical)
                        .lineLimit(5)
    }
}

struct TextFieldV02_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldV02(value: .constant(""), placeholder: "")
    }
}
