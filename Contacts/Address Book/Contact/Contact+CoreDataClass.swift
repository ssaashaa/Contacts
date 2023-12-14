//
//  Contact+CoreDataClass.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 14.12.2023.
//
//

import CoreData
import Foundation

@objc(Contact)
public class Contact: NSManagedObject {
    private static var identifierFactory: Int64 = 0
    
    private static func getUniqueIdentifier() -> Int64 {
        identifierFactory += 1
        return identifierFactory
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        self.identifier = Contact.getUniqueIdentifier()
    }
}
