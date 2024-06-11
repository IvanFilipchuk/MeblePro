//
//  SelectedContentView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct SelectedContentView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State var isShowMainLoginView = false
    var body: some View {
        
        if myAppVM.userSignedIn {
            TabBarView()
        } else if isShowMainLoginView {
           MainLoginView()
        } else {
            ProgressView()
                .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if !myAppVM.userSignedIn{
                                isShowMainLoginView = true
                                
                            }
                        }
                }
        }
    }
}

struct SelectedContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedContentView()
    }
}
