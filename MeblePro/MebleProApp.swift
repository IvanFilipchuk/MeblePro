//
//  MebleProApp.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

@main
struct MebleProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var myAppVM = MyAppViewModel()
    
    var body: some Scene {
        WindowGroup {
          RootContentView()
            
                .environmentObject(myAppVM)
        }
    }
}
