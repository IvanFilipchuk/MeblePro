//
//  AlertPresentationTests.swift
//  AlertPresentationTests
//
//  Created by Іван Філіпчук on 07/12/2023.
//

import XCTest
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
@testable import MeblePro

class AlertPresentationTests: XCTestCase {
    
    class MockViewModel: ObservableObject {
        @Published var customAlertInfo = CustomAlertInfo(title: "", description: "")
        @Published var isPresentAlert = false
    }

    class ViewModelWithAlert: ObservableObject {
        func showAlertWith(title: String, description: String, viewModel: MockViewModel) {
            DispatchQueue.main.async {
                viewModel.customAlertInfo.title = title
                viewModel.customAlertInfo.description = description
                viewModel.isPresentAlert = true
            }
        }
    }

    func testShowAlert() {
        let viewModel = MockViewModel()
        let viewModelWithAlert = ViewModelWithAlert()

        let expectation = XCTestExpectation(description: "Alert is presented")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(viewModel.customAlertInfo.title, "Test Title")
            XCTAssertEqual(viewModel.customAlertInfo.description, "Test Description")
            XCTAssertTrue(viewModel.isPresentAlert)
            expectation.fulfill()
        }

        viewModelWithAlert.showAlertWith(title: "Test Title", description: "Test Description", viewModel: viewModel)
    }
}
