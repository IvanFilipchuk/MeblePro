//
//  SignUpView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firmName = ""
    @State private var secureKod = ""

    var body: some View {
        List {
            Section {
                TextField("Imię", text: $firstName)
                TextField("Nazwisko", text: $lastName)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Hasło", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Powtórz hasło", text: $confirmPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
            } header: {
                Text("Dane osobowe")
            }
            
            Section {

                TextField("Nazwa Firmy", text: $firmName)
                SecureField("Klucz Firmy", text: $secureKod)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
              
            } header: {
                Text("Dane firmy")
            }
            
            Section {
                Button {
                                   if password == confirmPassword {
                                       myAppVM.signUp(firstName: firstName, lastName: lastName, email: email, password: password, companyName: firmName, companyKey: secureKod)
                                   } else {
                                       myAppVM.showAlertWith(title: "Błąd rejestracji", description: "Hasła nie są identyczne")
                                   }
                               } label: {
                                   Text("Zarejestruj się")
                               }
                               .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || firmName.isEmpty || secureKod.isEmpty)
                               
                Button(role: .destructive) {
                    firstName = ""
                    lastName = ""
                    email = ""
                    password = ""
                    confirmPassword = ""
                    firmName = ""
                    secureKod = ""
                } label: {
                    Text("Anuluj")
                }
                
            }
        }.navigationTitle("Rejestracja")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
