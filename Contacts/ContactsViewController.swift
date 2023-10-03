//
//  ViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 27.09.2023.
//

import UIKit

final class ContactsViewController: UITableViewController {
    
    private var contactNamesArray = [String]()
    private var contactPhoneNumbersArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        loadData()
    }
    
    // MARK: - UI
    
    private func configureNavigationBar() {
        title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addContact))
    }
    
    // MARK: - Method
    
    @objc private func addContact() {
        let alertController = UIAlertController(title: "Add contact info",
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            [weak self, weak alertController] _ in
            guard let textFields = alertController?.textFields, textFields.count == 2 else { return }
            let nameField = textFields[0]
            let numberField = textFields[1]
            
            if let name = nameField.text, let number = numberField.text {
                if !name.isEmpty {
                    self?.saveData(contactName: name, contactPhoneNumber: number)
                } else {
                    if let count = self?.contactNamesArray.count, let names = self?.contactNamesArray {
                        var index = 0
                        var unknownName = "Unknown"
                        while index < count {
                            if !names.contains(unknownName) {
                                self?.saveData(contactName: unknownName, contactPhoneNumber: number)
                                break
                            } else {
                                unknownName = "Unknown_\(index+1)"
                            }
                            index += 1
                        }
                    }
                }
                self?.tableView.reloadData()
            }
        })
        
        addAction.isEnabled = false
        alertController.addAction(addAction)
        
        alertController.addTextField { textField in
            textField.placeholder = "Please enter contact name"
            textField.textContentType = .name
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Please enter contact phone number"
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .phonePad
            textField.returnKeyType = .continue
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                addAction.isEnabled = (textField.text?.count ?? 0) > 0
            }
        }
        
        present(alertController, animated: true)
    }
    
    private func loadData() {
        if let contactNamesArray = UserDefaults.standard.stringArray(forKey: "names"),
           let contactPhoneNumbersArray = UserDefaults.standard.stringArray(forKey: "numbers") {
            self.contactNamesArray = contactNamesArray
            self.contactPhoneNumbersArray = contactPhoneNumbersArray
        }
        tableView.reloadData()
    }
    
    private func saveData(contactName: String, contactPhoneNumber: String) {
        contactNamesArray.append(contactName)
        contactPhoneNumbersArray.append(contactPhoneNumber)
        UserDefaults.standard.set(contactNamesArray, forKey: "names")
        UserDefaults.standard.set(contactPhoneNumbersArray, forKey: "numbers")
    }
    
}

// MARK: - Delegate

extension ContactsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactPhoneNumbersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath)
        // textLabel is deprecated
        cell.textLabel?.text = contactNamesArray[indexPath.row]
        return cell
    }
}

extension ContactsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let viewController = storyboard?.instantiateViewController(identifier: "ContactInfo") as? ContactInfoViewController {
            configureViewController(viewController, withContactIndex: indexPath.row)
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    private func configureViewController(_ viewController: ContactInfoViewController, withContactIndex index: Int) {
        viewController.contactName = contactNamesArray[index]
        viewController.contactPhoneNumber = contactPhoneNumbersArray[index]
        viewController.contactIndex = index
        viewController.updateContactsViewController = {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
}

