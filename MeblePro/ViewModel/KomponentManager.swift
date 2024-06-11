//
//  KomponentManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
    
    func addNewKomponent(komponentMaterial: String, komponentDlugosc: Int, komponentSzerokosc: Int,
                         komponentGrubosc: Int, komponentIlosc: Int, komponentJednostka: String,
                         komponentKolor: String, komponentUwagi: String?) {
        getUserCompanyInfo { companyRef in
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed dodaniem nowego komponentu.")
                return
            }
            let firestore = Firestore.firestore()
            let docPath = firestore.collection("companies").document(companyRef).collection("ElementList")

            guard self.validateComponentData(material: komponentMaterial, dlugosc: komponentDlugosc, szerokosc: komponentSzerokosc,
                                             grubosc: komponentGrubosc, ilosc: komponentIlosc, jednostka: komponentJednostka,
                                             kolor: komponentKolor, uwagi: komponentUwagi) else {
               
                self.showAlertWith(title: "Błąd walidacji",
                                   description: "Nieprawidłowe dane komponentu.")
                return
            }
            var addedComponentsCount = 0
            for _ in 0..<komponentIlosc {
                docPath.document().setData([
                    "text": komponentMaterial,
                    "dlugosc": komponentDlugosc,
                    "szerokosc": komponentSzerokosc,
                    "grubosc": komponentGrubosc,
                    "ilosc": 1,
                    "jednostka": komponentJednostka,
                    "kolor": komponentKolor,
                    "uwagi": komponentUwagi,
                    "isCompleted": false,
                    "dateCreated": Date(),
                    "userID": currentUserUID,
                ], merge: true) { error in
                    guard error == nil else {
                        self.showAlertWith(title: "Błąd dodawania komponentu",
                                           description: "Bląd: \(String(describing: error))")
                        return
                    }
                    addedComponentsCount += 1
                    if addedComponentsCount == komponentIlosc {
                        self.showAlertWith(title: "Dodanie elementu do bazy danych udane",
                                           description: "Pomyślne dodanie komponentu do systemu")
                    }
                }
            }
        }
    }
    
    func updateKomponent(updateKomponent: Komponent) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany", description: "Proszę zalogować się przed aktualizacją komponentu.")
                return
            }

            let firestore = Firestore.firestore()
            let docPath = firestore.collection("companies").document(companyRef).collection("ElementList")

            guard self.validateComponentData(material: updateKomponent.text, dlugosc: updateKomponent.dlugosc, szerokosc: updateKomponent.szerokosc, grubosc: updateKomponent.grubosc, ilosc: updateKomponent.ilosc, jednostka: updateKomponent.jednostka, kolor: updateKomponent.kolor, uwagi: updateKomponent.uwagi) else {
                self.showAlertWith(title: "Błąd walidacji", description: "Nieprawidłowe dane komponentu.")
                return
            }

            docPath.document(updateKomponent.id).updateData([
                "text": updateKomponent.text,
                "dlugosc": updateKomponent.dlugosc,
                "szerokosc": updateKomponent.szerokosc,
                "grubosc": updateKomponent.grubosc,
                "ilosc": updateKomponent.ilosc,
                "jednostka": updateKomponent.jednostka,
                "kolor": updateKomponent.kolor,
                "uwagi": updateKomponent.uwagi,
                "lastUpdated": FieldValue.serverTimestamp()
            ]) { error in
                guard error == nil else {
                    self.showAlertWith(title: "Błąd podczas aktualizacji komponentu", description: "Błąd aktualizacji komponentu w systemie: \(String(describing: error))")
                    return
                }

                self.showAlertWith(title: "Aktualizacja komponentu zakończona sukcesem", description: "Pomyślnie zaktualizowano komponent w Firestore")
            }
        }
    }
   
    
    func deleteKomponent(selectedKomponent: Komponent) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed usuwaniem komponentu.")
                return
            }
            
            let firestore = Firestore.firestore()

            firestore.collection("companies").document(companyRef).collection("ElementList").document(selectedKomponent.id).getDocument { (document, error) in
                if let error = error {
                    self.showAlertWith(title: "Błąd", description: "Błąd pobierania dokumentu komponentu: \(error.localizedDescription)")
                    return
                }

                if let elementData = document?.data() {
                    let deleteElementsCollection = firestore.collection("companies").document(companyRef).collection("DeleteElements")

                    deleteElementsCollection.addDocument(data: elementData) { error in
                        guard error == nil else {
                            self.showAlertWith(title: "Błąd dodawania do kosza", description: "Błąd: \(String(describing: error))")
                            return
                        }

                        firestore.collection("companies").document(companyRef).collection("ElementList").document(selectedKomponent.id).delete { error in
                            guard error == nil else {
                                self.showAlertWith(title: "Błąd usuwania komponentu", description: "Błąd: \(String(describing: error))")
                                return
                            }

                            self.allKomponents.removeAll(where: { $0.id == selectedKomponent.id })

                            self.showAlertWith(title: "Usuwanie komponentu", description: "Komponent został pomyślnie usunięty i przeniesiony do kosza")
                        }
                    }
                } else {
                    self.showAlertWith(title: "Błąd", description: "Dane komponentu nie zostały znalezione.")
                }
            }
        }
    }
  
    func runRealTimeListenerKomponentList() {
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
                let elementListPath = Firestore.firestore().collection("companies").document(companyKey).collection("ElementList").order(by: "dateCreated")
                
                elementListPath.addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        if self?.auth.currentUser != nil {
                            self?.showAlertWith(title: "Błąd odczytu listy komponentów w czasie rzeczywistym", description: "Błąd: \(String(describing: error))")
                        } else {
                            print("Real-Time List Listener Error")
                        }
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        self?.showAlertWith(title: "Brak danych w querySnapshot", description: "Błąd: brak danych (listy komponentów) w querySnapshot")
                        return
                    }
                    
                    var tempArrayOfTasks = [Komponent]()
                    for document in querySnapshot.documents {
                        let documentData = document.data()
                        let taskID = document.documentID
                        let taskText = documentData["text"] as? String ?? ""
                        let taskDlugosc = documentData["dlugosc"] as? Int ?? 0
                        let taskSzerokosc = documentData["szerokosc"] as? Int ?? 0
                        let taskGrubosc = documentData["grubosc"] as? Int ?? 0
                        let taskIlosc = documentData["ilosc"] as? Int ?? 0
                        let taskJednostka = documentData["jednostka"] as? String ?? ""
                        let taskKolor = documentData["kolor"] as? String ?? ""
                        let taskUwagi = documentData["uwagi"] as? String ?? ""
                        let rawTaskDate = documentData["dateCreated"] as? Timestamp ?? Timestamp(date: Date())
                        let dateCreated = rawTaskDate.dateValue()
                        let lastUpdated = (documentData["lastUpdated"] as? Timestamp)?.dateValue()
                        let isCompleted = documentData["isCompleted"] as? Bool ?? false
                        
                        let newTask = Komponent(id: taskID,
                                           text: taskText,
                                           dlugosc: taskDlugosc,
                                           szerokosc: taskSzerokosc ,
                                           ilosc: taskIlosc,
                                           grubosc:taskGrubosc,
                                           jednostka:taskJednostka,
                                           kolor: taskKolor,
                                           uwagi: taskUwagi,
                                           dateCreated: dateCreated,
                                           isCompleted: isCompleted,
                                           lastUpdated: lastUpdated)
                        tempArrayOfTasks.append(newTask)
                    }
                    
                    DispatchQueue.main.async {
                        [weak self] in
                        self?.allKomponents = tempArrayOfTasks
                    }
                }
            } else {
            }
        }
    }
    
    
}
