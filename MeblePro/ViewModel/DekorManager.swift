//
//  KolorManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
    
    func addNewDekor(dekorName: String, dekorKodname: String) {
        getUserCompanyInfo { companyRef in
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed dodaniem nowego dekoru.")
                return
            }
            let firestore = Firestore.firestore()
            let docPath = firestore.collection("companies").document(companyRef).collection("KolorList")
            guard self.validateDekorData(name: dekorName, kodname:dekorKodname) else {
               
                self.showAlertWith(title: "Błąd walidacji",
                                   description: "Nieprawidłowe dane dekoru.")
                return
            }
            firestore.collection("companies").document(companyRef).collection("KolorList").addDocument(data: [
                "name": dekorName,
                "kodname": dekorKodname,
                "userID": currentUserUID
            ]) { error in
                guard error == nil else {
                    self.showAlertWith(title: "Błąd dodawania dekoru", description: "Błąd: \(String(describing: error))")
                    return
                }
                self.showAlertWith(title: "Dodano dekor", description: "Pomyślnie dodano dekor do systemu")
            }
        }
    }
    
    func deleteDekor(selectedDekors: Dekor) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed dodaniem nowego dekoru.")
                return
            }
            let firestore = Firestore.firestore()

            firestore.collection("companies").document(companyRef).collection("KolorList").document(selectedDekors.id).delete { [weak self] error in
                guard error == nil else {
                    self?.showAlertWith(title: "Błąd usuwania dekoru", description: "Błąd: \(String(describing: error))")
                    return
                }

                self?.allDekors.removeAll(where: { $0.id == selectedDekors.id })
                self?.showAlertWith(title: "Usunięcie dekoru", description: "Dekor został pomyślnie usunięty.")
            }
        }
    }
    
    func runRealTimeListenerDekorList() {
         guard let currentUserUID = Auth.auth().currentUser?.uid else {
             return
         }
         let userRef = Firestore.firestore().collection("users").document(currentUserUID)
         userRef.getDocument { [weak self] (document, error) in
             guard error == nil else {
                 return
             }
             guard let document = document, document.exists else {
                 return
             }
             
             let companyKey = document["companyKey"] as? String
             if let companyKey = companyKey {
                 let elementListPath = Firestore.firestore().collection("companies").document(companyKey).collection("KolorList")
                 elementListPath.addSnapshotListener { querySnapshot, error in
                     guard error == nil else {
                         if self?.auth.currentUser != nil {
                             self?.showAlertWith(title: "Błąd odczytu danych czasie rzeczywistym", description: "Błąd: \(String(describing: error))")
                         } else {
                             print("Real-Time List Listener Error")
                         }
                         return
                     }
                     
                     guard let querySnapshot = querySnapshot else {
                         self?.showAlertWith(title: "Brak danych w querySnapshot", description: "Błąd: brak danych (listy dekorów) w querySnapshot")
                         return
                     }
                     
                     var tempArrayOfKolors = [Dekor]()
                     for document in querySnapshot.documents {
                         let documentData = document.data()
                         let dekorID = document.documentID
                         let dekorName = documentData["name"] as? String ?? ""
                         let dekorKodname = documentData["kodname"] as? String ?? ""
                         
                         
                         let newKolor = Dekor(id: dekorID,
                                              name: dekorName,
                                              kodname:dekorKodname)
                         
                         tempArrayOfKolors.append(newKolor)
                     }
                     
                     DispatchQueue.main.async {
                         [weak self] in
                         self?.allDekors = tempArrayOfKolors
                     }
                 }
             } else {
             }
         }
     }
    
}
