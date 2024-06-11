//
//  MainLoginView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct MainLoginView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    
    var body: some View {
        ZStack {
            Image("bg1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing) {
                Spacer()
                VStack{
                    Text("Witamy w ")
                    Text("MeblePro !")
                }
                    .font(
                        .custom(
                        "AmericanTypewriter",
                        fixedSize: 40)
                        .weight(.semibold))
                    .frame(width:340,alignment: .trailing )
                
                VStack(alignment: .trailing) {
                    NavigationLink("Zaloguj się", value: "signIn")
                        .signInSignUpButtonStyle()
                    
                    NavigationLink("Zarejestruj się", value: "signUp")
                        .signInSignUpButtonStyle()
                }
                Spacer()
            }
        }
    }
}

struct MainLoginView_Previews: PreviewProvider {
    static var previews: some View {
        MainLoginView()
    }
}
