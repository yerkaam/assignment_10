//
//  Note.swift
//  NoteAppCoreData
//
//  Created by Yerdaulet Orynbay on 08.12.2024.
//

import CoreData

@objc(Note)
class Note: NSManagedObject
{
    @NSManaged var id: NSNumber!
    @NSManaged var title: String!
    @NSManaged var desc: String!
    @NSManaged var deletedDate: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var createdAt: Date?
}
