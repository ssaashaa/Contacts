//
//  ContactsUITestsLaunchTests.swift
//  ContactsUITests
//
//  Created by Sasha Stryapkov on 19.01.2024.
//

import XCTest

final class ContactsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.buttons["Add"].exists)
        
        let button = app.buttons.element(boundBy: 0)
        button.tap()
                
        let loginTextField = app.textFields.element(boundBy: 0)
        loginTextField.tap()
        XCTAssertTrue(loginTextField.isSelected)
        loginTextField.typeText("Cock")
        loginTextField.doubleTap()
        XCTAssertEqual(loginTextField.value as! String, "Cock")
        


        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

//        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch Screen"
//        attachment.lifetime = .keepAlways
//        add(attachment)
    }
}
