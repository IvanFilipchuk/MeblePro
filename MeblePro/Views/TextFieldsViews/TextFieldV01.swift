//
//  TextFieldV01.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct TextFieldV01: View {
    @Binding var value: String
    
    var body: some View {
        ZStack {
            TextEditor(text: $value)
            Text(value).opacity(0).padding(.all, 8)
                .lineLimit(5)
        }
    }
}

struct TextFieldV01_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldV01(value: .constant(""))
    }
}
