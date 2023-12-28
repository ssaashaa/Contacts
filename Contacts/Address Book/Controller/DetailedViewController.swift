//
//  DetailedViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 13.12.2023.
//

import UIKit

final class DetailedViewController: UIViewController {
    @IBOutlet private weak var contactNameLabel: UILabel!
    @IBOutlet private weak var contactNameTextField: UITextField!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var dbService: DBService?
    var contact: Contact?
    
    private var isEditMode = false {
        willSet {
            guard isEditMode != newValue else {
                return
            }
        }
        didSet {
            changeViewMode(isEditMode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        setContactInfo()
    }
    
    // MARK: - Set UI
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapEditButton))
    }
    
    private func setTextFields() {
        contactNameTextField.layer.borderColor = TextFieldBorder.base.color
        contactNameTextField.layer.borderWidth = 1
        contactNameTextField.layer.cornerRadius = 10
        
        phoneNumberTextField.layer.borderColor = TextFieldBorder.base.color
        phoneNumberTextField.layer.borderWidth = 1
        phoneNumberTextField.layer.cornerRadius = 10
    }
    
    private func setDeleteButton() {
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self,
                               action: #selector(didTapDeleteButton),
                               for: .touchUpInside)
    }
    
    private func setView() {
        setNavigationBar()
        setTextFields()
        setDeleteButton()
    }
    
    private func setContactInfo() {
        contactNameTextField.text = ""
        phoneNumberTextField.text = ""
        
        guard let contact = contact else {
            return
        }
        
        contactNameTextField.text = contact.fullName
        phoneNumberTextField.text = contact.phoneNumber
    }
    
    // MARK: - Change UI
    
    private func changeNavigationBarMode(_ editMode: Bool) {
        if !editMode {
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Save"
        }
    }
    
    private func changeContactNameTextFieldMode(_ editMode: Bool) {
        contactNameTextField.isEnabled = editMode
        contactNameTextField.layer.borderColor = editMode ? TextFieldBorder.edit.color : TextFieldBorder.base.color
        
        if editMode {
            addContactNameTextFieldObserver()
        } else {
            removeTextFieldObserver(contactNameTextField)
        }
    }
    
    private func changePhoneNumberTextFieldMode(_ editMode: Bool) {
        phoneNumberTextField.isEnabled = editMode
        phoneNumberTextField.layer.borderColor = editMode ? TextFieldBorder.edit.color : TextFieldBorder.base.color
        
        if editMode {
            addPhoneNumberTextFieldObserver()
        } else {
            removeTextFieldObserver(phoneNumberTextField)
        }
    }
    
    private func changeDeleteButtonMode(_ editMode: Bool) {
        if !editMode {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
        }
    }
    
    private func changeViewMode(_ editMode: Bool) {
        changeNavigationBarMode(editMode)
        changeContactNameTextFieldMode(editMode)
        changePhoneNumberTextFieldMode(editMode)
        changeDeleteButtonMode(editMode)
    }
    
    // MARK: - Observer
    
    private func addContactNameTextFieldObserver() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                               object: contactNameTextField,
                                               queue: OperationQueue.main) { [weak self] _ in
            if let charactersInNameTextFieldCount = self?.contactNameTextField.text?.count,
               let charactersInNumbersTextFieldCount = self?.phoneNumberTextField.text?.count {
                
                if charactersInNameTextFieldCount > 0 && charactersInNumbersTextFieldCount > 0 {
                    self?.contactNameTextField.layer.borderColor = TextFieldBorder.edit.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                } else if charactersInNameTextFieldCount > 0 && charactersInNumbersTextFieldCount == 0 {
                    self?.contactNameTextField.layer.borderColor = TextFieldBorder.edit.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                } else if charactersInNameTextFieldCount == 0 {
                    self?.contactNameTextField.layer.borderColor = TextFieldBorder.error.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        }
    }
    
    private func addPhoneNumberTextFieldObserver() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                               object: phoneNumberTextField,
                                               queue: OperationQueue.main) { [weak self] _ in
            if let charactersInNumbersTextFieldCount = self?.phoneNumberTextField.text?.count,
               let charactersInNameTextFieldCount = self?.contactNameTextField.text?.count {
                
                if charactersInNumbersTextFieldCount > 0 && charactersInNameTextFieldCount > 0 {
                    self?.phoneNumberTextField.layer.borderColor = TextFieldBorder.edit.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                } else if charactersInNumbersTextFieldCount > 0 && charactersInNameTextFieldCount == 0 {
                    self?.phoneNumberTextField.layer.borderColor = TextFieldBorder.edit.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                } else if charactersInNumbersTextFieldCount == 0 {
                    self?.phoneNumberTextField.layer.borderColor = TextFieldBorder.error.color
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }
        }
    }
    
    private func removeTextFieldObserver(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextField.textDidChangeNotification,
                                                  object: textField)
    }
    
    // MARK: - Method
    
    @objc private func didTapEditButton() {
        guard isEditMode else {
            isEditMode = !isEditMode
            return
        }
        
        guard let id = contact?.identifier else { return }
        
        if let oldName = contact?.fullName,
           let oldPhoneNumber = contact?.phoneNumber,
           let newName = contactNameTextField.text,
           let newPhoneNumber = phoneNumberTextField.text {
            guard oldName != newName || oldPhoneNumber != newPhoneNumber else { isEditMode = !isEditMode; return }
            dbService?.editContact(identifier: id,
                                   newFullName: newName,
                                   newPhoneNumber: newPhoneNumber)
        }

        isEditMode = !isEditMode
    }
    
    @objc private func didTapDeleteButton() {
        let alertController = UIAlertController(title: "Are you sure?",
                                                message: "This action will delete the contact information permanently",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel))
        
        let deleteContactAction = UIAlertAction(title: "Delete",
                                                style: .destructive,
                                                handler: {[weak self] _ in
            guard let id = self?.contact?.identifier else { return }
            self?.dbService?.deleteContact(id)
            self?.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(deleteContactAction)
        
        present(alertController, animated: true)
    }
}
