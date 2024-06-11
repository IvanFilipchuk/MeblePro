//
//  EditUserView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct EditUserView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @Environment(\.dismiss) var dismiss
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        List {
            Section {
                TextField("Imię", text: $firstName)
                TextField("Nazwisko", text: $lastName)
            } header: {
                Text("Imię i Nazwisko")
            }
            Section {
                Button {
                    myAppVM.updateUserData(firstName: firstName, lastName: lastName)
                } label: {
                    Text("Zaktualizuj użytkownika")
                        .frame(maxWidth: .infinity, alignment: .center)
                }.disabled(firstName.isEmpty || lastName.isEmpty)
            }
            Section {
                TextField("Email", text: $email)
                    
            } header: {
                Text("Email")
            }
            Section {
                Button {
                    myAppVM.updateUsersEmailAuth(email: email)
                } label: {
                    Text("Zaktualizuj email")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Edycja użytkownika")
    }
}

struct EditUserView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserView()
    }
}
