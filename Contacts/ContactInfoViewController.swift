//
//  ContactInfoViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 28.09.2023.
//

import UIKit

final class ContactInfoViewController: UIViewController {
    var contactName: String?
    var contactPhoneNumber: String?
    var contactIndex: Int?
    private var isEditModeOn = false
    
    var updateContactsViewController: (() -> Void)?
    
    private let contactNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Contact Name:"
        return label
    }()
    
    private let contactNumberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Phone Number:"
        return label
    }()
    
    private var contactNameTextField = PaddedTextField(frame: .zero)
    private var contactNumberTextField = PaddedTextField(frame: .zero)
    private let deleteButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureConstraints()
    }
    
    // MARK: - UI
    
    private func configureView() {
        configureNavBar()
        configureTextField(&contactNameTextField,
                           withPlaceholder: "Please enter contact name",
                           andText: contactName)
        configureTextField(&contactNumberTextField,
                           withPlaceholder: "Please enter contact phone number",
                           andText: contactPhoneNumber)
        configureDeleteButton()

        view.addSubview(contactNameLabel)
        view.addSubview(contactNameTextField)
        view.addSubview(contactNumberLabel)
        view.addSubview(contactNumberTextField)
        view.addSubview(deleteButton)
    }
    
    private func configureNavBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapEditButton))
    }
    
    private func configureTextField(_ textField: inout PaddedTextField,
                                    withPlaceholder placeholder: String,
                                    andText text: String?)
    {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.font = .systemFont(ofSize: 15)
        textField.textContentType = .name
        textField.autocapitalizationType = .words
        textField.returnKeyType = .next
        textField.placeholder = placeholder
        textField.text = text
        textField.isEnabled = false
    }
    
    private func configureDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.layer.cornerRadius = 10
        deleteButton.backgroundColor = .red
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        deleteButton.isHidden = true
    }
    
    private func changeNavBarMode(_ editMode: Bool) {
        if !editMode {
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Save"
        } else {
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    private func changeTextFieldsMode(_ editMode: Bool) {
        if !editMode {
            contactNameTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
            contactNumberTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
            
            contactNameTextField.isEnabled = true
            contactNumberTextField.isEnabled = true
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: contactNameTextField, queue: OperationQueue.main) { [weak self] _ in
                self?.navigationItem.rightBarButtonItem?.isEnabled = (self?.contactNameTextField.text?.count ?? 0) > 0 && (self?.contactNumberTextField.text?.count ?? 0) > 0
            }
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: contactNumberTextField, queue: OperationQueue.main) { [weak self] _ in
                self?.navigationItem.rightBarButtonItem?.isEnabled = (self?.contactNumberTextField.text?.count ?? 0) > 0 && (self?.contactNameTextField.text?.count ?? 0) > 0
            }
        } else {
            contactNameTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            contactNumberTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            
            contactNameTextField.isEnabled = false
            contactNumberTextField.isEnabled = false
            
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: contactNameTextField)
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: contactNumberTextField)
        }
    }
    
    private func changeDeleteButtonMode(_ editMode: Bool) {
        if !editMode {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            contactNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contactNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contactNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            contactNameTextField.topAnchor.constraint(equalTo: contactNameLabel.bottomAnchor, constant: 20),
            contactNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            contactNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            contactNumberLabel.topAnchor.constraint(equalTo: contactNameTextField.bottomAnchor, constant: 30),
            contactNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contactNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactNumberLabel.heightAnchor.constraint(equalToConstant: 20),
            
            contactNumberTextField.topAnchor.constraint(equalTo: contactNumberLabel.bottomAnchor, constant: 20),
            contactNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            contactNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactNumberTextField.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(greaterThanOrEqualTo: contactNumberTextField.bottomAnchor, constant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.widthAnchor.constraint(equalToConstant: 150),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Methods
    
    @objc private func didTapEditButton() {
        changeContactInfo(isEditModeOn)
    }
    
    private func changeContactInfo(_ editMode: Bool) {
        updateEditModeView(editMode)
        saveNewContactInfo()
        isEditModeOn = !editMode
    }
    
    private func updateEditModeView(_ editMode: Bool) {
        changeNavBarMode(editMode)
        changeTextFieldsMode(editMode)
        changeDeleteButtonMode(editMode)
    }
    
    private func updateContactInfo(withName name: String, number: String, andIndex contactIndex: Int) {
       if var contactNamesArray = UserDefaults.standard.stringArray(forKey: "names"),
          var contactNumbersArray = UserDefaults.standard.stringArray(forKey: "numbers") {
           if contactNamesArray[contactIndex] != name {
               contactNamesArray[contactIndex] = name
               UserDefaults.standard.set(contactNamesArray, forKey: "names")
           }
           if contactNumbersArray[contactIndex] != number {
               contactNumbersArray[contactIndex] = number
               UserDefaults.standard.set(contactNumbersArray, forKey: "numbers")
           }
       }
        updateContactsViewController?()
    }
    
    private func saveNewContactInfo() {
        if let newName = contactNameTextField.text,
           let newNumber = contactNumberTextField.text,
           let contactPostion = contactIndex {
            updateContactInfo(withName: newName, number: newNumber, andIndex: contactPostion)
        }
    }
    
    private func removeContact(atIndex contactIndex: Int) {
        if var contactNamesArray = UserDefaults.standard.stringArray(forKey: "names"),
           var contactNumbersArray = UserDefaults.standard.stringArray(forKey: "numbers") {
            contactNamesArray.remove(at: contactIndex)
            contactNumbersArray.remove(at: contactIndex)
            UserDefaults.standard.set(contactNamesArray, forKey: "names")
            UserDefaults.standard.set(contactNumbersArray, forKey: "numbers")
        }
        updateContactsViewController?()
    }
    
    @objc private func didTapDeleteButton() {
        if let contactIndex = contactIndex {
            removeContact(atIndex: contactIndex)
            navigationController?.popViewController(animated: true)
        }
    }
}
