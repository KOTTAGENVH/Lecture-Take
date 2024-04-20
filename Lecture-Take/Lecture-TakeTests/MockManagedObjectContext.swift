//
//  MockManagedObjectContext.swift
//  Lecture-TakeTests
//
//  Created by Nowen on 2024-04-20.
//

import Foundation
import CoreData

// Mock NSManagedObjectContext class to simulate Core Data behavior for testing
class MockManagedObjectContext: NSManagedObjectContext {
    var mockObjects: [Note] = []

    // Override the fetch method to return mock objects
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        return mockObjects
    }
}
