//
//  checkEmailTest.swift
//  checkEmailTest
//
//  Created by Іван Філіпчук on 06/12/2023.
//

import XCTest
import FirebaseAuth
import FirebaseFirestore
import Firebase
@testable import MeblePro

class CheckEmailTest: XCTestCase {

    var viewModel: MyAppViewModel!

    override func setUpWithError() throws {
        viewModel = MyAppViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testCheckEmailWithValidEmail() throws {
        let isValid = viewModel.checkEmail(email: "test@example.com")
        XCTAssertTrue(isValid, "Email validation failed for a valid email.")
    }

    func testCheckEmailWithInvalidEmail() throws {
        let isValid = viewModel.checkEmail(email: "invalid_email")
        XCTAssertFalse(isValid, "Email validation passed for an invalid email.")
    }
}

