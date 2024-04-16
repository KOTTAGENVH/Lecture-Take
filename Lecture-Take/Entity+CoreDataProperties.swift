//
//  Entity+CoreDataProperties.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-16.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var attribute: Int32

}

extension Entity : Identifiable {

}
