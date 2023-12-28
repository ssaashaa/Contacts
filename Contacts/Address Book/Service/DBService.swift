//
//  DBService.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 28.12.2023.
//

import CoreData
import UIKit

protocol DBDelegate: AnyObject {
    func addressBookFetched(_ addressBook: [Contact])
    func contactFetched(_ contact: Contact)
}

final class DBService {
    var delegate: DBDelegate?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAddressBook() {
        var objects = [Contact]()
        
        do {
            objects = try context.fetch(Contact.fetchRequest())
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.delegate?.addressBookFetched(objects)
        }
    }
    
    func addContact(fullName: String?, phoneNumber: String?) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Contact",
                                                      in: context) else { return }
        
        let taskObject = Contact(entity: entity, insertInto: context)
        
        taskObject.identifier = UUID().uuidString
        
        if let fullName = fullName, let phoneNumber = phoneNumber {
            if fullName != "" {
                taskObject.fullName = fullName
            } else {
                taskObject.fullName = "Unknown_\(taskObject.identifier ?? "???")"
            }
            taskObject.phoneNumber = phoneNumber
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.delegate?.contactFetched(taskObject)
        }
    }
    
    func editContact(identifier: String,
                     newFullName: String,
                     newPhoneNumber: String) {
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let objects = try? context.fetch(fetchRequest) else { return }
        
        for object in objects where object.identifier == identifier {
            object.fullName = newFullName
            object.phoneNumber = newPhoneNumber
            break
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.delegate?.addressBookFetched(objects)
        }
    }
    
    func deleteContact(_ identifier: String) {
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard var objects = try? context.fetch(fetchRequest) else { return }
        var objectId = 0
        
        for (id, object) in objects.enumerated() where object.identifier == identifier {
            objectId = id
            context.delete(object)
            break
        }
        
        objects.remove(at: objectId)
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.delegate?.addressBookFetched(objects)
        }
    }
}
