//
//  fetchcoredata.swift
//  Lecture-TakeTests
//
//  Created by Nowen on 2024-04-20.
//

import XCTest
@testable import Lecture_Take

class NoteTableViewTests: XCTestCase {
    
    var noteTableView: NoteTableView!
    
    override func setUp() {
        super.setUp()
        noteTableView = NoteTableView()
    }
    
    override func tearDown() {
        noteTableView = nil
        super.tearDown()
    }
    
    //    // Test if CoreData fetching returns any notes
    //    func testLoadDataFetchesCoreData() {
    //        // Assuming CoreData has some test data
    //        noteTableView.loadData()
    //
    //        XCTAssertFalse(noteList.isEmpty, "CoreData fetching should return some notes")
    //    }
    //
    //
    //    // Test if CoreData fetching populates noteList when there is no error
    //    func testLoadDataPopulatesNoteList() {
    //        // Ensure no error condition by setting firstLoad flag to false
    //        noteTableView.firstLoad = false
    //
    //        // Call loadData, which should fetch CoreData without error
    //        noteTableView.loadData()
    //
    //        // Check if noteList is not empty when there is no error
    //        XCTAssertFalse(noteList.isEmpty, "CoreData fetching should populate noteList when there is no error")
    //    }
    //}
}
