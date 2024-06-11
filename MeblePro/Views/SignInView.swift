//
//  SignInView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State var email = ""
    @State var password = ""

    var body: some View {
        List {
            Section {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Hasło", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                Text("Dane logowania")
            }
            Section {
                Button {
                    myAppVM.signIn(email: email, password: password)
                } label: {
                    Text("Zaloguj się")
                }
                .disabled(email.isEmpty || password.isEmpty)
                Button(role: .destructive) {
                    email = ""
                    password = ""
                } label: {
                    Text("Anuluj")
                }
                
            }
        }.navigationTitle("Logowanie")
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
