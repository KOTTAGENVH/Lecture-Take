//
//  LectureNote+CoreDataProperties.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-16.
//
//

import Foundation
import CoreData


extension LectureNotes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LectureNote> {
        return NSFetchRequest<LectureNote>(entityName: "LectureNote")
    }

    @NSManaged public var date: Date?
    @NSManaged public var descriptionNote: String?
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var image: Data?

}

extension LectureNotes : Identifiable {

}
