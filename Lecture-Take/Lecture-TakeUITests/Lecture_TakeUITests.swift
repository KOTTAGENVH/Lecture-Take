//
//  Lecture_TakeUITests.swift
//  Lecture-TakeUITests
//
//  Created by Nowen on 2024-04-12.
//

import XCTest

final class Lecture_TakeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testNoteTableView() throws {
        let app = XCUIApplication()
        app.launch()

        // Ensure that the "Add" button exists and tap on it
        XCTAssertTrue(app.navigationBars["Home"].buttons["Add"].exists)
        app.navigationBars["Home"].buttons["Add"].tap()

//         Assert that the navigation bar title changes to "Note" when Add button is tapped
        XCTAssertTrue(app.navigationBars["Note"].exists)

        // Tap on the "Home" button to navigate back
        app.navigationBars["Note"].buttons["Home"].tap()
    }
}

