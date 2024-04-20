//
//  Lecture_TakeUITestsLaunchTests.swift
//  Lecture-TakeUITests
//
//  Created by Nowen on 2024-04-12.
//

import XCTest

class NoteTableViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

}

