//
//  AppDelegate.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//


import Foundation
import Firebase
 
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}
