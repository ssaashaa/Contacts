//
//  ViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 27.09.2023.
//

import UIKit

final class ContactsViewController: UITableViewController {
    
    private var names = [String]()
    private var numbers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        loadData()
    }
    
    // MARK: - UI
    
    private func configureNavigationBar() {
        title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContact))
    }
    
    // MARK: - Method
    
    @objc private func addContact() {
        let ac = UIAlertController(title: "Add contact info", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            [weak self, weak ac] _ in
            guard let textFields = ac?.textFields, textFields.count == 2 else { return }
            let nameField = textFields[0]
            let numberField = textFields[1]
            
            if let name = nameField.text, let number = numberField.text {
                if !name.isEmpty {
                    self?.saveData(name: name, number: number)
                } else {
                    if let count = self?.names.count, let names = self?.names {
                        var index = 0
                        var unknownName = "Unknown"
                        while index < count {
                            if !names.contains(unknownName) {
                                self?.saveData(name: unknownName, number: number)
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
        ac.addAction(addAction)
        
        ac.addTextField { textField in
            textField.placeholder = "Please enter contact name"
            textField.textContentType = .name
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        }
        
        ac.addTextField { textField in
            textField.placeholder = "Please enter contact phone number"
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .phonePad
            textField.returnKeyType = .continue
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                addAction.isEnabled = (textField.text?.count ?? 0) > 0
            }
        }
        
        present(ac, animated: true)
    }
    
    private func loadData() {
        if let names = UserDefaults.standard.stringArray(forKey: "names"),
           let numbers = UserDefaults.standard.stringArray(forKey: "numbers") {
            self.names = names
            self.numbers = numbers
        }
        tableView.reloadData()
    }
    
    private func saveData(name: String, number: String) {
        names.append(name)
        numbers.append(number)
        UserDefaults.standard.set(names, forKey: "names")
        UserDefaults.standard.set(numbers, forKey: "numbers")
    }
    
}

// MARK: - Delegate

extension ContactsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numbers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath)
        // textLabel is deprecated
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
}

extension ContactsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard?.instantiateViewController(identifier: "ContactInfo") as! ContactInfoViewController
        vc.name = names[indexPath.row]
        vc.number = numbers[indexPath.row]
        vc.index = indexPath.row
        vc.update = {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

