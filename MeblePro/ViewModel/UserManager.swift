//
//  UserManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
   
    func updateUserData(firstName: String, lastName: String) {
        guard let currentUser = auth.currentUser else {
            self.showAlertWith(title: "Użytkownik niezalogowany",
                               description: "Proszę zalogować się ")
            return
        }
        let currentUserUID = currentUser.uid
        let currentUserEmail = currentUser.email ?? ""
        db.collection("users").document(currentUserUID).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": currentUserEmail,
            "lastUpdated": FieldValue.serverTimestamp()
        ], merge: true) { [weak self] userUpdateError in
            if let userUpdateError = userUpdateError {
                print("Error updating user data: \(userUpdateError.localizedDescription)")
                self?.showAlertWith(title: "Błąd podczas aktualizacji danych użytkownika", description: "Błąd: \(userUpdateError.localizedDescription)")
                return
            }
            self?.updateCompanyUserData(firstName: firstName, lastName: lastName, email: currentUserEmail)
            self?.showAlertWith(title: "Aktualizacja zakończona sukcesem", description: "Aktualizacja danych użytkownika zakończona sukcesem")
        }
    }

    func updateCompanyUserData(firstName: String, lastName: String, email: String) {
        guard let currentUser = auth.currentUser else {
            self.showAlertWith(title: "Użytkownik niezalogowany",
                               description: "Proszę zalogować się ")
            return
        }
        let currentUserUID = currentUser.uid
        let firestore = Firestore.firestore()
        let docRef = firestore.collection("users").document(currentUserUID)
        docRef.getDocument { (document, error) in
            if let err = error {
                print("Błąd podczas pobierania dokumentu \(err)")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                if let companyKey = data?["companyKey"] as? String {
                    let companyUserDocRef = firestore.collection("companies").document(companyKey).collection("users").document(currentUserUID)
                    companyUserDocRef.setData(["firstName": firstName, "lastName": lastName, "email": email, "companyKey": companyKey],
                        merge: true) { companyUserUpdateError in
                        if let companyUserUpdateError = companyUserUpdateError {
                            print("Error updating company user data: \(companyUserUpdateError.localizedDescription)")
                            self.showAlertWith(title: "Błąd podczas aktualizacji adresu email użytkownika", description: "Błąd: \(companyUserUpdateError.localizedDescription)")
                            return
                        }
                    }
                }
            } else {
                print("Dokument użytkownika nie znaleziony")
            }
        }
    }

    func updateUsersEmailAuth(email: String) {
        
        auth.currentUser?.updateEmail(to: email) { [weak self] error in
            guard error == nil else {
                self?.showAlertWith(title: "Błąd podczas aktualizacji adresu email użytkownika", description: "Błąd podczas aktualizacji adresu email użytkownika w systemie \(String(describing: error))")
                print("Error with updating users' email in Firebase Auth. \(String(describing: error))")
                return
            }
            self?.updateUsersEmailDB(email: email)
        }
    }
    
    func updateUsersEmailDB(email: String) {
        guard let currentUser = auth.currentUser else {
            self.showAlertWith(title: "Użytkownik niezalogowany",
                               description: "Proszę zalogować się ")
            return
        }

        let currentUserUID = currentUser.uid

        db.collection("users").document(currentUserUID).updateData(["email" : email, "lastUpdated" : FieldValue.serverTimestamp()]) { [weak self] error in
            guard error == nil else {
                self?.showAlertWith(title: "Błąd podczas aktualizacji adresu email użytkownika", description: "Błąd podczas aktualizacji adresu email użytkownika w systemie \(String(describing: error))")
                return
            }
            
            let docRef = Firestore.firestore().collection("users").document(currentUserUID)
            docRef.getDocument { (document, error) in
                if let err = error {
                    print("Błąd podczas pobierania dokumentu \(err)")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let companyKey = data?["companyKey"] as? String {
                        let companyUserDocRef = Firestore.firestore().collection("companies").document(companyKey).collection("users").document(currentUserUID)
                        companyUserDocRef.updateData(["email": email]) { companyUserUpdateError in
                            if let companyUserUpdateError = companyUserUpdateError {
                                print("Error updating company user email: \(companyUserUpdateError.localizedDescription)")
                                self?.showAlertWith(title: "Błąd podczas aktualizacji adresu email użytkownika", description: "Błąd: \(companyUserUpdateError.localizedDescription)")
                                return
                            }
                        }
                    }
                } else {
                    print("Dokument użytkownika nie znaleziony")
                }
            }
        }
    }
    
    func runRealTimeListenerUserData() {
        let currentUserUID = auth.currentUser?.uid ?? ""
        let docPath = db.collection("users").document(currentUserUID)
        docPath.addSnapshotListener { [weak self] documentSnapshot, error in
            guard error == nil else {
                if self?.auth.currentUser != nil {
                    self?.showAlertWith(title: "Error: Real-Time User Updates", description: "Error: \(String(describing: error))")
                } else {
                    print("Error: \(String(describing: error))")
                }
                return
            }
            
            guard let document = documentSnapshot else {
                self?.showAlertWith(title: "Error: documentSnapshot == nil", description: "documentSnapshot == nil, we don't take date from DB")
                return
            }
            
            let firstName = document["firstName"] as? String ?? ""
            let lastName = document["lastName"] as? String ?? ""
            let companyKey = document["companyKey"] as? String ?? ""
            let companyName = document["companyName"] as? String ?? ""
            let emailDB = document["email"] as? String ?? ""
            let newUser = User(id: currentUserUID, firstName: firstName, lastName: lastName, email: emailDB, companyName: companyName, companyKey: companyKey)
            DispatchQueue.main.async {
                self?.mainUser = newUser
            }
        }
    }
}
    
