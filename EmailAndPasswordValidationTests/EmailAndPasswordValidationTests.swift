//
//  EmailAndPasswordValidationTests.swift
//  EmailAndPasswordValidationTests
//
//  Created by Іван Філіпчук on 07/12/2023.
//

import XCTest
import FirebaseAuth
import FirebaseFirestore
import Firebase
@testable import MeblePro

class EmailAndPasswordValidationTests: XCTestCase {
    func testValidEmailAndPassword() {
        let viewModel = MyAppViewModel()
        let isValid = viewModel.checkEmailAndPassword(email: "test@example.com", password: "password123")
        XCTAssertTrue(isValid, "Email and password should be valid")
    }
    func testInvalidEmailAndShortPassword() {
        let viewModel = MyAppViewModel()
        let isValid = viewModel.checkEmailAndPassword(email: "invalid-email", password: "short")
        XCTAssertFalse(isValid, "Email and password should be invalid")
    }
    func testInvalidEmail() {
        let viewModel = MyAppViewModel()
        let isValid = viewModel.checkEmailAndPassword(email: "invalid-email", password: "password123")
        XCTAssertFalse(isValid, "Email should be invalid")
    }
    func testShortPassword() {
        let viewModel = MyAppViewModel()
        let isValid = viewModel.checkEmailAndPassword(email: "test@example.com", password: "short")
        XCTAssertFalse(isValid, "Password should be too short")
    }
}

