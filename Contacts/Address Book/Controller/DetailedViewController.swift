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
    
    var model: Model?
    var contact: Contact?
    
    private var isInEditMode = false {
        willSet {
            guard isInEditMode != newValue else {
                return
            }
        }
        didSet {
            changeViewMode(isInEditMode)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contactNameTextField.text = ""
        phoneNumberTextField.text = ""
        
        guard let contact = contact else {
            return
        }
        
        contactNameTextField.text = contact.fullName
        phoneNumberTextField.text = contact.phoneNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    // MARK: - UI
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapEditButton))
    }
    
    private func setTextFields() {
        contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.defaultColor
        contactNameTextField.layer.borderWidth = 1
        contactNameTextField.layer.cornerRadius = 10
        
        phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.defaultColor
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
    
    private func changeNavigationBarMode(_ editMode: Bool) {
        if !editMode {
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Save"
        }
    }
    
    private func changeTextFieldMode(_ editMode: Bool) {
        if !editMode {
            contactNameTextField.isEnabled = false
            contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.defaultColor
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextField.textDidChangeNotification,
                                                      object: contactNameTextField)
            
            phoneNumberTextField.isEnabled = false
            phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.defaultColor
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextField.textDidChangeNotification,
                                                      object: phoneNumberTextField)
        } else {
            contactNameTextField.isEnabled = true
            contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: contactNameTextField,
                                                   queue: OperationQueue.main) { [weak self] _ in
                if let charactersInNameTextFieldCount = self?.contactNameTextField.text?.count,
                   let charactersInNumbersTextFieldCount = self?.phoneNumberTextField.text?.count {
                    
                    if charactersInNameTextFieldCount > 0 && charactersInNumbersTextFieldCount > 0 {
                        self?.contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    } else if charactersInNameTextFieldCount > 0 && charactersInNumbersTextFieldCount == 0 {
                        self?.contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    } else if charactersInNameTextFieldCount == 0 {
                        self?.contactNameTextField.layer.borderColor = BorderColorTextFieldConstants.errorColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                }
            }
            
            phoneNumberTextField.isEnabled = true
            phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: phoneNumberTextField,
                                                   queue: OperationQueue.main) { [weak self] _ in
                if let charactersInNumbersTextFieldCount = self?.phoneNumberTextField.text?.count,
                   let charactersInNameTextFieldCount = self?.contactNameTextField.text?.count {
                    
                    if charactersInNumbersTextFieldCount > 0 && charactersInNameTextFieldCount > 0 {
                        self?.phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    } else if charactersInNumbersTextFieldCount > 0 && charactersInNameTextFieldCount == 0 {
                        self?.phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.editModeColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    } else if charactersInNumbersTextFieldCount == 0 {
                        self?.phoneNumberTextField.layer.borderColor = BorderColorTextFieldConstants.errorColor
                        self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                }
            }
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
        changeTextFieldMode(editMode)
        changeDeleteButtonMode(editMode)
    }
    
    // MARK: - Method
    
    @objc private func didTapEditButton() {
        guard isInEditMode else {
            isInEditMode = !isInEditMode
            return
        }
        
        guard let id = contact?.identifier else { return }
        model?.editContact(contactIdentifier: id,
                           newFullName: contactNameTextField.text,
                           newPhoneNumber: phoneNumberTextField.text)
        
        isInEditMode = !isInEditMode
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
            self?.model?.deleteContact(id)
            self?.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(deleteContactAction)
        
        present(alertController, animated: true)
    }
}
