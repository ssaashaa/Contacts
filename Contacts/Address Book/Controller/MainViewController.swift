//
//  MainViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 12.12.2023.
//

import UIKit

final class MainViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private var dbService = DBService()
    private var addressBook = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dbService.delegate = self
        dbService.getAddressBook()
        
        setNavigationBar()
    }
    
    // MARK: - Set UI
    
    private func setNavigationBar() {
        title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
    }
    
    // MARK: - Method
    
    @objc private func didTapAddButton() {
        let addContactAlert = createAddContactAlert()
        present(addContactAlert, animated: true)
    }
    
    private func createAddContactAlert() -> UIAlertController {
        let alertController = UIAlertController(title: "Add contact info",
                                                message: nil,
                                                preferredStyle: .alert)
        
        let addContactAction = createAddContactAction(alertController)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel))
        
        alertController.addAction(addContactAction)
        
        createAlertTextFields(alertController: alertController,
                              action: addContactAction)
        
        return alertController
    }
    
    private func createAddContactAction(_ alertController: UIAlertController) -> UIAlertAction {
        let addContactAction = UIAlertAction(title: "Add",
                                             style: .default,
                                             handler: {[weak self, weak alertController] _ in
            guard let textFields = alertController?.textFields, textFields.count == 2 else { return }
            
            let nameField = textFields[0]
            let numberField = textFields[1]
            
            self?.dbService.addContact(fullName: nameField.text,
                                       phoneNumber: numberField.text)
        })
        
        addContactAction.isEnabled = false
                
        return addContactAction
    }
    
    private func createAlertTextFields(alertController: UIAlertController, action: UIAlertAction) {
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
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: textField,
                                                   queue: OperationQueue.main) { _ in
                action.isEnabled = (textField.text?.count ?? 0) > 0
            }
        }
    }
}

// MARK: - DB Service Delegate

extension MainViewController: DBDelegate {
    func addressBookFetched(_ addressBook: [Contact]) {
        self.addressBook = addressBook
        tableView.reloadData()
    }
    
    func contactFetched(_ contact: Contact) {
        self.addressBook.append(contact)
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source & Delegate

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addressBook.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath) as! ContactTableViewCell
        let contact = addressBook[indexPath.row]
        if let fullName = contact.fullName {
            cell.setCell(fullName)
        }
        
        return cell
    }
}

// MARK: - Segue

extension MainViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        
        let contact = addressBook[indexPath.row]
        
        guard let detailedViewController = segue.destination as? DetailedViewController else { return }
        detailedViewController.contact = contact
        detailedViewController.dbService = dbService
    }
}
