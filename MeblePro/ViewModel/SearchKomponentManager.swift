//
//  SearchKomponentManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
    
    
    func addKomponentToTaskList(selectedKomponent: Komponent, searchDlugosc: Int, searchSzerokosc: Int, searchGrubosc: Int, searchKolor: String, szerokoscPily: Int) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed wyszukiwaniem komponentu.")
                return
            }
            let firestore = Firestore.firestore()

            firestore.collection("companies").document(companyRef).collection("ElementList").document(selectedKomponent.id).getDocument { [weak self] (document, error) in
                if let error = error {
                    self?.showAlertWith(title: "Błąd", description: "Błąd podczas pobierania dokumentu elementu: \(error.localizedDescription)")
                    return
                }

                if let elementData = document?.data() {
                    let searchElementsCollection = firestore.collection("companies").document(companyRef).collection("SearchElements")
                    var searchElementData = elementData
                    searchElementData["searchDlugosc"] = searchDlugosc
                    searchElementData["searchSzerokosc"] = searchSzerokosc
                    searchElementData["searchGrubosc"] = searchGrubosc
                    searchElementData["searchKolor"] = searchKolor
                    searchElementData["szerokoscPily"] = szerokoscPily
                    searchElementsCollection.addDocument(data: searchElementData) { error in
                        guard error == nil else {
                            self?.showAlertWith(title: "Błąd dodawania do zadania", description: "Błąd: \(String(describing: error))")
                            return
                        }

                        firestore.collection("companies").document(companyRef).collection("ElementList").document(selectedKomponent.id).delete { error in
                            guard error == nil else {
                                self?.showAlertWith(title: "Błąd usuwania komponentu z ogólnej listy", description: "Błąd: \(String(describing: error))")
                                return
                            }

                            if let index = self?.allKomponents.firstIndex(where: { $0.id == selectedKomponent.id }) {
                                self?.allKomponents.remove(at: index)
                            }
                            self?.showAlertWith(title: "Dodanie nowego zadania", description: "Wyszukany komponent został dodany do listy zadań.")
                        }
                    }
                } else {
                    self?.showAlertWith(title: "Błąd", description: "Nie znaleziono danych elementu.")
                }
            }
        }
    }

    func updateTasksStatus(selectedTask: SearchKomponent) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed wyszukiwaniem komponentu.")
                return
            }
            let firestore = Firestore.firestore()
            var isCompletedTask = !selectedTask.isCompleted
            firestore.collection("companies").document(companyRef).collection("SearchElements").document(selectedTask.id).updateData(["isCompleted": isCompletedTask, "lastUpdated": FieldValue.serverTimestamp()]) { [weak self] error in
                guard error == nil else {
                    self?.showAlertWith(title: "Błąd aktualizacji zadania", description: "Błąd aktualizacji zadania w bazie danych: \(String(describing: error))")
                    return
                }
                self?.showAlertWith(title: "Zadanie zrealizowane", description: "Zadanie zostało pomyślnie zrealizowane.")
            }
        }
    }
    
    func runRealTimeListenerSearchElementList() {
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
                let elementListPath = Firestore.firestore().collection("companies").document(companyKey).collection("SearchElements").order(by: "dateCreated")
                
                elementListPath.addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        if self?.auth.currentUser != nil {
                            self?.showAlertWith(title: "Błąd odczytu listy zadan w czasie rzeczywistym", description: "Error: \(String(describing: error))")
                        } else {
                            print("Real-Time List Listener Error")
                        }
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        self?.showAlertWith(title: "Brak danych w querySnapshot", description: "Błąd: brak danych (listy zadań) w querySnapshot")
                        return
                    }
                    var tempArrayOfTasks = [SearchKomponent]()
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
                        let isCompleted = documentData["isCompleted"] as? Bool ?? false
                        let searchDlugosc = documentData["searchDlugosc"] as? Int ?? 0
                        let searchSzerokosc = documentData["searchSzerokosc"] as? Int ?? 0
                        let searchGrubosc = documentData["searchGrubosc"] as? Int ?? 0
                        let searchKolor = documentData["searchKolor"] as? String ?? ""
                        let szerokoscPily = documentData["szerokoscPily"] as? Int ?? 0
                        let userID = documentData["userID"] as? String ?? ""
                        let newSearchElement = SearchKomponent(id: taskID,
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
                                                             userID: userID,
                                                             searchDlugosc:searchDlugosc,
                                                             searchSzerokosc: searchSzerokosc,
                                                             searchGrubosc: searchGrubosc,
                                                             searchKolor:searchKolor,
                                                             szerokoscPily: szerokoscPily)
                        tempArrayOfTasks.append(newSearchElement)
                    }
                    
                    DispatchQueue.main.async {
                        [weak self] in
                        self?.allSearchKomponents = tempArrayOfTasks
                    }
                }
            } else {
            }
        }
    }
}
