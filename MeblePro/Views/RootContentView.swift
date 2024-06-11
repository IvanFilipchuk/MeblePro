//
//  RootContentView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct RootContentView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    
    var body: some View {
        NavigationStack(path: $myAppVM.path) {
            SelectedContentView()
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "signIn":
                        SignInView()
                    case "signUp":
                        SignUpView()
                    case "setting":
                        UserView()
                    default: Text("Default View")
                    }
                
               }.navigationDestination(for: Komponent.self, destination: { komponent in
                   EditKomponentView(komponentMaterial: komponent.text,
                                komponentDlugosc: komponent.dlugosc,
                                komponentSzerokosc: komponent.szerokosc,
                                komponentGrubosc: komponent.grubosc,
                                komponentIlosc: komponent.ilosc,
                                komponentJednostka: komponent.jednostka,
                                komponentKolor: komponent.kolor,
                                komponentUwagi:  komponent.uwagi,
                                komponent: komponent)
                })
               .navigationDestination(for: Komponent.self, destination: { komponent in
                   EditKomponentView()
               })
               .navigationDestination(for: SearchKomponent.self, destination: { searchKomponent in
                   TaskView(taskText: searchKomponent.text,
                                taskDlugosc: searchKomponent.dlugosc,
                                taskSzerokosc: searchKomponent.szerokosc,
                                taskGrubosc: searchKomponent.grubosc,
                                taskIlosc: searchKomponent.ilosc,
                                taskJednostka: searchKomponent.jednostka,
                                taskKolor: searchKomponent.kolor,
                                taskUwagi:  searchKomponent.uwagi,
                                searchDlugosc: searchKomponent.searchDlugosc,
                                searchSzerokosc: searchKomponent.searchSzerokosc,
                                searchGrubosc: searchKomponent.searchGrubosc,
                                szerokoscPily:searchKomponent.szerokoscPily,
                                searchKolor: searchKomponent.searchKolor,
                                searchElement: searchKomponent)
                   
                })
               .navigationDestination(for: SearchKomponent.self, destination: { searchKomponent in
                  TaskView()
               })
                .navigationDestination(for: User.self, destination: { user in
                    EditUserView(firstName: user.firstName, lastName: user.lastName, email: user.email)                })
                .alert(myAppVM.customAlertInfo.title, isPresented: $myAppVM.isPresentAlert, actions: {
                }, message: {
                    Text(myAppVM.customAlertInfo.description)
                })
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    myAppVM.isUserSignedIn()
                }
        }
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView()
    }
}

