//
//  LectureNotes+CoreDataProperties.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-16.
//
//

import Foundation
import CoreData


extension LectureNotes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LectureNotes> {
        return NSFetchRequest<LectureNotes>(entityName: "LectureNotes")
    }

    @NSManaged public var date: Date?
    @NSManaged public var descriptionNote: String?
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var deletedDate: Date?

}

extension LectureNotes : Identifiable {

}
