//
//  Contact+CoreDataProperties.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 14.12.2023.
//
//

import CoreData
import Foundation

extension Contact {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var identifier: Int64
}

extension Contact: Identifiable {

}
