//
//  DeletedKomponentManager.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 25/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestore

extension MyAppViewModel {
   
    func deleteDeletedKomponent(selectedDeletedKomponent: DeletedKomponent) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed usuwaniem komponentu.")
                return
            }
            let firestore = Firestore.firestore()

            firestore.collection("companies").document(companyRef).collection("DeleteElements").document(selectedDeletedKomponent.id).delete { [weak self] error in
                guard error == nil else {
                    self?.showAlertWith(title: "Błąd usuwania komponentu", description: "Błąd: \(String(describing: error))")
                    return
                }

                self?.allDeletedKomponents.removeAll(where: { $0.id == selectedDeletedKomponent.id })
                self?.showAlertWith(title: "Usunięcie komponentu", description: "Komponent został pomyślnie usunięty bez możliwości przywrócenia.")
            }
        }
    }
    
    func restoreKomponentFromTrash(removedKomponent: DeletedKomponent) {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed przywracaniem komponentu.")
                return
            }
            
            let firestore = Firestore.firestore()
            firestore.collection("companies").document(companyRef).collection("DeleteElements").document(removedKomponent.id).getDocument { [weak self] (document, error) in
                if let error = error {
                    self?.showAlertWith(title: "Błąd", description: "Błąd podczas pobierania dokumentu usuniętego komponentu: \(error.localizedDescription)")
                    return
                }
                if let deletedElementData = document?.data() {
                    let elementListCollection = firestore.collection("companies").document(companyRef).collection("ElementList")

                    elementListCollection.addDocument(data: deletedElementData) { error in
                        guard error == nil else {
                            self?.showAlertWith(title: "Błąd przywracania komponentu", description: "Błąd: \(String(describing: error))")
                            return
                        }
                        firestore.collection("companies").document(companyRef).collection("DeleteElements").document(removedKomponent.id).delete { error in
                            guard error == nil else {
                                self?.showAlertWith(title: "Błąd przywracania komponentu", description: "Błąd: \(String(describing: error))")
                                return
                            }
                            self?.allKomponents.removeAll(where: { $0.id == removedKomponent.id })

                            self?.showAlertWith(title: "Przywracanie komponentu", description: "Komponent przywrócony pomyślnie.")
                        }
                    }
                } else {
                    self?.showAlertWith(title: "Błąd", description: "Nie znaleziono danych usuniętego komponentu.")
                }
            }
        }
    }
    
    func deleteAllDeletedKomponents() {
        getUserCompanyInfo { companyRef in
            guard (Auth.auth().currentUser?.uid) != nil else {
                self.showAlertWith(title: "Użytkownik niezalogowany",
                                   description: "Proszę zalogować się przed usuwania wszystkich komponentów z kosza.")
                return
            }
            let firestore = Firestore.firestore()
            firestore.collection("companies").document(companyRef).collection("DeleteElements").getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    self?.showAlertWith(title: "Błąd usuwania komponentów z kosza", description: "Błąd: \(String(describing: error))")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    self?.showAlertWith(title: "Błąd", description: "Brak dokumentów w kolekcji DeleteElements.")
                    return
                }
                let batch = firestore.batch()

                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { [weak self] error in
                    guard error == nil else {
                        self?.showAlertWith(title: "Błąd usuwania komponentów z kosza", description: "Błąd: \(String(describing: error))")
                        return
                    }

                    self?.allDeletedKomponents.removeAll()
                    self?.showAlertWith(title: "Kosz został wyczyszczony", description: "Wszystkie komponenty w koszu zostały usunięte bez możliwości przywrócenia.")
                }
            }
        }
    }
    
    func runRealTimeListenerDeletedElements() {
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
                let elementListPath = Firestore.firestore().collection("companies").document(companyKey).collection("DeleteElements").order(by: "dateCreated")
                elementListPath.addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        if self?.auth.currentUser != nil {
                            self?.showAlertWith(title: "Błąd odczytu listy usunientych komponentów w czasie rzeczywistym", description: "Błąd: \(String(describing: error))")
                        } else {
                            print("Real-Time List Listener Error")
                        }
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        self?.showAlertWith(title: "Brak danych w querySnapshot", description: "Błąd: brak danych (listy komponentów) w querySnapshot")
                        return
                    }
                    
                    var tempArrayOfTasks = [DeletedKomponent]()
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
                        
                        let newTask = DeletedKomponent(id: taskID,
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
                        self?.allDeletedKomponents = tempArrayOfTasks
                    }
                }
            } else {
            }
        }
    }
}
