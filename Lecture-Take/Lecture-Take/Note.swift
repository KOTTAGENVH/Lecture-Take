//
//  Note.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-17.
//


import CoreData
import UIKit

@objc(Note)
class Note: NSManagedObject
{
    @NSManaged var id: NSNumber!
    @NSManaged var title: String!
    @NSManaged var desc: String!
    @NSManaged var deletedDate: Date?
    @NSManaged var date: Date?
//    @NSManaged var image: Data?
}

