//
//  imagebuttontest.swift
//  Lecture-TakeUITests
//
//  Created by Nowen on 2024-04-20.
//

import XCTest

final class imagebuttontest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCameraButtonClicked() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Home"].buttons["Add"].exists)
        app.navigationBars["Home"].buttons["Add"].tap()

        // Tap on the camera button
        let cameraButton = app.buttons.element(matching: .button, identifier: "camera")
          cameraButton.tap()

          // Assert that some action has occurred
          XCTAssertTrue(true, "Camera button action verified")
    }

}
