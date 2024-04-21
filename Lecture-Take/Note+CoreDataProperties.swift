//
//  Note+CoreDataProperties.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-18.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var date: Date?
    @NSManaged public var deletedDate: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var imageData: Data?

}

extension Note : Identifiable {

}
