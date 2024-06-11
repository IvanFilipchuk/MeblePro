//
//  AddNewElementUTest.swift
//  AddNewElementUTest
//
//  Created by Іван Філіпчук on 06/12/2023.
//

import XCTest
import FirebaseAuth
import FirebaseFirestore
import Firebase
@testable import MeblePro

final class AddKomponentToTaskListTest: XCTestCase {
    
    var viewModel: MyAppViewModel!
    let testCompanyKey = "testCompanyKey"
    let testUserID = "testUserID"
    
    override func setUp() {
        super.setUp()
        FirebaseApp.configure()
        viewModel = MyAppViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testAddKomponentToTaskList() {
        
        let testElement = Komponent(id: "testID", text: "Testowy Materiał", dlugosc: 100, szerokosc: 50, ilosc: 1, grubosc: 10, jednostka: "mm", kolor: "Dąb Antyczny", uwagi: "Testowe uwagi", dateCreated: Date(), isCompleted: false)
        
        viewModel.addNewKomponent(
            elementText: testElement.text,
            elementDlugosc: testElement.dlugosc,
            elementSzerokosc: testElement.szerokosc,
            elementGrubosc: testElement.grubosc,
            elementIlosc: testElement.ilosc,
            elementJednostka: testElement.jednostka,
            elementKolor: testElement.kolor,
            elementUwagi: testElement.uwagi
        )
        
        viewModel.addKomponentToTaskList(
            selectedKomponent: testElement,
            searchDlugosc: 100,
            searchSzerokosc: 50,
            searchGrubosc: 10,
            searchKolor: "Czerwony",
            szerokoscPily: 2
        )
        let firestore = Firestore.firestore()
        let collection = firestore.collection("companies").document(testCompanyKey).collection("ElementList")
        collection.document(testElement.id).getDocument { (document, error) in
            XCTAssertNotNil(error, "Error should not be nil since the element should be deleted")
            XCTAssertNil(document, "Document should be nil since the element should be deleted")
        }
        let searchElementsCollection = firestore.collection("companies").document(testCompanyKey).collection("SearchElements")
        searchElementsCollection.whereField("text", isEqualTo: testElement.text).getDocuments { (querySnapshot, error) in
            XCTAssertNil(error, "Error should be nil")
            XCTAssertNotNil(querySnapshot, "Query snapshot should not be nil")
            XCTAssertEqual(querySnapshot?.documents.count, 1, "Should find exactly one document")
            
            let document = querySnapshot?.documents.first
            XCTAssertEqual(document?.data()["searchDlugosc"] as? Int, 100)
            XCTAssertEqual(document?.data()["searchSzerokosc"] as? Int, 50)
            XCTAssertEqual(document?.data()["searchGrubosc"] as? Int, 10)
            XCTAssertEqual(document?.data()["searchKolor"] as? String, "Czerwony")
            XCTAssertEqual(document?.data()["szerokoscPily"] as? Int, 2)
        }
    }
}
