//
//  Lecture_TakeTests.swift
//  Lecture-TakeTests
//
//  Created by Nowen on 2024-04-12.
//

import XCTest
@testable import Lecture_Take
import CoreData

class Lecture_TakeTests: XCTestCase {
    
    var viewController: NoteDetailViewController!
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "addTask") as? NoteDetailViewController
        viewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        viewController = nil
    }
    
  


      func testSaveActionWithEmptyTitle() throws {
          // Given
          viewController.titlefield.text = ""

          // When
          viewController.saveAction(UIButton())

          // Then
          XCTAssertNil(viewController.selectedNote, "Selected note should be nil when title is empty")
      }

    
    func testStartRecording() throws {
           // Ensure audio engine is not running initially
           XCTAssertFalse(viewController.audioEngine.isRunning)
           
           // Call startRecording
           viewController.startRecording()
           
           // Audio engine should be running after calling startRecording
           XCTAssertTrue(viewController.audioEngine.isRunning)
       }
       
       func testStopRecording() throws {
           // Call startRecording to ensure audio engine is running
           viewController.startRecording()
           
           // Audio engine should be running before calling stopRecording
           XCTAssertTrue(viewController.audioEngine.isRunning)
           
           // Call stopRecording
           viewController.stopRecording()
           
           // Audio engine should not be running after calling stopRecording
           XCTAssertFalse(viewController.audioEngine.isRunning)
       }

    
}



