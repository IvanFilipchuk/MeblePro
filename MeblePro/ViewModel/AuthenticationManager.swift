//
//  AuthenticationManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
    
    func signUp(firstName: String, lastName: String, email: String, password: String, companyName: String, companyKey: String) {
      Auth.auth().createUser(withEmail: email, password: password) {
          [weak self] result, error in
          guard error == nil else {
              self?.showAlertWith(title: "Błąd rejestracji",
                                  description: "Błąd: \(String(describing: error))")
              print("Błąd rejestracji \(String(describing: error))")
              return
          }
          guard let mainResult = result else {
              self?.showAlertWith(title: "Brak danych",
                                  description: "Wynik z danymi użytkownika jest pusty")
              return
          }
          let userUID = mainResult.user.uid
          guard let userEmail = result?.user.email else {
              print("Błąd pobierania adresu email użytkownika")
              self?.showAlertWith(title: "Błąd pobierania danych użytkownika",
                                  description: "Błąd: 'result?.user.email == nil' ")
              return
          }
          print("Rejestracja z adresem email: \(userEmail)\n")
          
          let firestore = Firestore.firestore()
          let companyDocRef = firestore.collection("companies").document(companyKey)
          companyDocRef.setData(["CompanyName": companyName, "CompanyKey ": companyKey], merge: true){ error in
              guard error == nil else {
                  self?.showAlertWith(title: "Błąd zapisu danych firmy",
                                      description: "Błąd: \(String(describing: error))")
                  return
              }
          }
          let companyUserDocRef = firestore.collection("companies").document(companyKey).collection("users").document(userUID)
          
          companyUserDocRef.setData(["firstName": firstName, "lastName": lastName, "email": userEmail, "companyKey": companyKey],
                                    merge: true) {
              error in
              guard error == nil else {
                  self?.showAlertWith(title: "Błąd zapisu danych użytkownika",
                                      description: "Błąd: \(String(describing: error))")
                  return
              }
          }
          let userDocRef = firestore.collection("users").document(userUID)
          userDocRef.setData(["firstName": firstName, "lastName": lastName, "email": userEmail,
                              "companyName": companyName, "companyKey": companyKey], merge: true) { error in
              guard error == nil else {
                  self?.showAlertWith(title: "Błąd zapisu danych użytkownika",
                                      description: "Błąd: \(String(describing: error))")
                  return
              }
          }
          self?.backToRootScreen()
      }
  }
  
    func signIn(email: String, password: String) {
      guard checkEmailAndPassword(email: email, password: password) == true else {
          print("Błąd podczas sprawdzania adresu email i hasła")
          return
      }
              auth.signIn(withEmail: email, password: password)
      { [weak self]
          result, error in
          guard error == nil else {
              print("Błąd logowania z adresem email: \(String(describing: error))")
              self?.showAlertWith(title: "Błąd logowania",
                                  description: "Błąd: \(String(describing: error))")
              return
          }
          guard let userEmail = result?.user.email else {
              print("Błąd pobierania 'result?.user.email'")
              self?.showAlertWith(title: "Błąd pobierania danych użytkownika",
                                  description: "Błąd: 'result?.user.email == nil'")
              return
          }
          print("Zalogowano z adresem email: \(userEmail)\n")
          self?.backToRootScreen()
      }
  }

    func signOut() {
        do {
            try auth.signOut()
        } catch {
            showAlertWith(title: "Błąd wylogowania",
                          description: "Błąd: \(error)")
        }
        isUserSignedIn()
        backToRootScreen()
    }
    
    func runAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] auth, user in
            
            if let user = user {
                if let providerData = auth.currentUser?.providerData {
                    for userInfo in providerData {
                        switch userInfo.providerID {
                        case "google.com":
                            self?.isGoogleProvider = true
                        default:
                            self?.isGoogleProvider = true
                        }
                    }
                }
                print("User Real-Time UID: \(user.uid)")
                print("Auth Real-Time UID: \(String(describing: auth.currentUser?.uid))")
                
            } else {
                print("Sign Out")
                self?.isRunInitTasks = true
                self?.backToRootScreen()
                self?.isGoogleProvider = false
            }
        }
        
    }
}
    
