//
//  UserView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        Text(myAppVM.mainUser.firstName)
                        Text(myAppVM.mainUser.lastName)
                    } header: {
                        Text("Dane osobowe")
                    }
                    Section {
                        Text(myAppVM.mainUser.companyName)
                        Text(myAppVM.mainUser.companyKey)
                        
                    } header: {
                        Text("Dane Firmy")
                    }
                    
                    Section {
                        Text(myAppVM.mainUser.email)
                    } header: {
                        Text("Email")
                    }
                    Section {
                        NavigationLink(value: myAppVM.mainUser) {
                            Text("Edytuj dane użytkownika")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } header: {
                        Text("Edycja Użytkownika")
                    }
                    Section {
                        Toggle("Tryb nocny", isOn: $isDarkModeEnabled)
                            .padding()
                            .onChange(of: isDarkModeEnabled) { newValue in
                                UIApplication.shared.windows.first?.rootViewController?.view.overrideUserInterfaceStyle = newValue ? .dark : .light
                            }
                    } header: {
                        Text("Tryb nocny")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        myAppVM.signOut()
                    }) {
                        Image(systemName: "square.and.arrow.up.fill")
                    }
                }
            }
            .navigationTitle("")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
