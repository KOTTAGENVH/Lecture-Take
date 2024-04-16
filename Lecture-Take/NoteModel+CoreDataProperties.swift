//
//  NoteModel+CoreDataProperties.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-16.
//
//

import Foundation
import CoreData


extension NoteModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteModel> {
        return NSFetchRequest<NoteModel>(entityName: "NoteModel")
    }

    @NSManaged public var title: String?
    @NSManaged public var descriptionNote: String?
    @NSManaged public var image: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: Int32

}

extension NoteModel : Identifiable {

}
