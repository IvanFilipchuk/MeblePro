//
//  MyAppViewModel.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class MyAppViewModel: ObservableObject {
     
    @Published var userSignedIn: Bool = false
    @Published var path = NavigationPath()
    let auth = Auth.auth()
    @Published var isPresentAlert = false
    @Published var customAlertInfo = CustomAlertInfo(title: "", description: "")
    @Published var mainUser = User(id: "", firstName: "", lastName: "", email: "", companyName: "", companyKey: "")
    let db = Firestore.firestore()
    @Published var allKomponents = [Komponent]()
    @Published var allDekors = [Dekor]()
    @Published var allSearchKomponents = [SearchKomponent]()
    @Published var allDeletedKomponents = [DeletedKomponent]()
    @Published var isRunInitTasks = true
    @Published var isGoogleProvider = false
    @Published var currentUserFirmId: String = ""

    func showAlertWith(title: String, description: String) {
        DispatchQueue.main.async {
            [weak self] in
            self?.customAlertInfo.title = title
            self?.customAlertInfo.description = description
            self?.isPresentAlert = true
        }
    }
    
    let formatDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    func backToRootScreen() {
        DispatchQueue.main.async {
            [weak self] in
            self?.path = .init()
        }
    }
    
    func isUserSignedIn() {
        let result = auth.currentUser != nil
        
        if result {
            if isRunInitTasks {
                runAuthStateListener()
                runRealTimeListenerUserData()
                runRealTimeListenerKomponentList()
                runRealTimeListenerDekorList()
                runRealTimeListenerSearchElementList()
                runRealTimeListenerDeletedElements()
                isRunInitTasks.toggle()
            }
            
        }
        DispatchQueue.main.async {
            [weak self] in
            self?.userSignedIn = result
        }
    }

    func checkEmailAndPassword(email: String, password: String) -> Bool {
        let isValidEmail = email.isValidEmail
        let isValidPassword = password.count >= 6
        switch (isValidEmail, isValidPassword) {
        case (true, true):
            return true
        case (false, false):
            showAlertWith(title: "Nieprawidłowy email i hasło", description: "Email jest nieprawidłowy, a hasło ma mniej niż 6 znaków.")
            return false
        case (false, _):
            showAlertWith(title: "Nieprawidłowy email", description: "Niepoprawny format adresu email.")
            return false
        case (_, false):
            showAlertWith(title: "Nieprawidłowe hasło", description: "Twoje hasło ma mniej niż 6 znaków. Proszę podać dłuższe hasło.")
            return false
        }
        
    }
    
    func checkEmail(email: String) -> Bool {
        let isValidEmail = email.isValidEmail
        switch isValidEmail {
        case true:
            return true
        case false: showAlertWith(title: "Nieprawidłowy email", description: "Niepoprawny format adresu email.")
            return false
        }
    }
    
    func getUserCompanyInfo(completion: @escaping (String) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            showAlertWith(title: "Użytkownik niezalogowany",
                          description: "Proszę zalogować się do systemu! ")
            return
        }
        var companyRef = ""
        let firestore = Firestore.firestore()
        let docRef = firestore.collection("users").document(currentUserUID)
        
        docRef.getDocument { (document, error) in
            if let err = error {
                print("Błąd podczas pobierania dokumentu \(err)")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                companyRef = data?["companyKey"] as? String ?? ""
                
                completion(companyRef)
            } else {
                print("Dokument użytkownika nie znaleziony")
            }
        }
    }
    
    func validateComponentData(material: String, dlugosc: Int, szerokosc: Int, grubosc: Int, ilosc: Int, jednostka: String, kolor: String, uwagi: String?) -> Bool {
        guard !material.isEmpty else {
            return false
        }
        guard !jednostka.isEmpty else {
            return false
        }
        guard dlugosc > 0, szerokosc > 0, grubosc > 0, ilosc > 0 else {
            return false
        }
        let maxDigits = 5
        guard String(dlugosc).count <= maxDigits,
              String(szerokosc).count <= maxDigits,
              String(grubosc).count <= maxDigits,
              String(ilosc).count <= maxDigits else {
            return false
        }
        guard !kolor.isEmpty else {
            return false
        }

        if let uwagi = uwagi {
            guard uwagi is String else {
                return false
            }
        }
        return true
    }
    
    func validateDekorData(name: String, kodname: String) -> Bool {
        guard !name.isEmpty else {
            return false
        }
        guard !kodname.isEmpty, kodname.count >= 5, kodname.first?.isUppercase == true, kodname.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil else {
                return false
            }
        return true
    }
}
