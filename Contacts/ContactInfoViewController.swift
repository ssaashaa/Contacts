//
//  ContactInfoViewController.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 28.09.2023.
//

import UIKit

final class ContactInfoViewController: UIViewController {
    var name: String?
    var number: String?
    var index: Int?
    var isEditModeOn = false
    
    var update: (() -> Void)?
    
    private let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Contact Name:"
        return label
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Phone Number:"
        return label
    }()
    
    private var nameTextField = PaddedTextField(frame: .zero)
    private var numberTextField = PaddedTextField(frame: .zero)
    private let deleteButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureConstraints()
    }
    
    // MARK: - UI
    
    private func configureView() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditButton))
        
        nameTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 10
        nameTextField.font = .systemFont(ofSize: 15)
        nameTextField.textContentType = .name
        nameTextField.autocapitalizationType = .words
        nameTextField.returnKeyType = .next
        nameTextField.placeholder = "Please enter contact name"
        nameTextField.text = name
        nameTextField.isEnabled = false
        
        numberTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        numberTextField.layer.borderWidth = 1
        numberTextField.layer.cornerRadius = 10
        numberTextField.font = .systemFont(ofSize: 15)
        numberTextField.textContentType = .telephoneNumber
        numberTextField.keyboardType = .phonePad
        numberTextField.returnKeyType = .continue
        numberTextField.text = number
        numberTextField.placeholder = "Please enter contact phone number"
        numberTextField.isEnabled = false
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.layer.cornerRadius = 10
        deleteButton.backgroundColor = .red
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        deleteButton.isHidden = true
        
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(numberLabel)
        view.addSubview(numberTextField)
        view.addSubview(deleteButton)
    }
    
    private func configureConstraints() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            numberLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            numberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberLabel.heightAnchor.constraint(equalToConstant: 20),
            
            numberTextField.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 20),
            numberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            numberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberTextField.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(greaterThanOrEqualTo: numberTextField.bottomAnchor, constant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.widthAnchor.constraint(equalToConstant: 150),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Methods
    
    @objc private func didTapEditButton() {
        isEditModeOn ? turnOffEditMode() : turnOnEditMode()
    }
    
    private func turnOnEditMode() {
        isEditModeOn = true
        
        navigationItem.rightBarButtonItem?.style = .done
        navigationItem.rightBarButtonItem?.title = "Save"
        nameTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        numberTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        
        deleteButton.isHidden = false
        
        nameTextField.isEnabled = true
        numberTextField.isEnabled = true
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nameTextField, queue: OperationQueue.main) { [weak self] _ in
            self?.navigationItem.rightBarButtonItem?.isEnabled = (self?.nameTextField.text?.count ?? 0) > 0 && (self?.numberTextField.text?.count ?? 0) > 0
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: numberTextField, queue: OperationQueue.main) { [weak self] _ in
            self?.navigationItem.rightBarButtonItem?.isEnabled = (self?.numberTextField.text?.count ?? 0) > 0 && (self?.nameTextField.text?.count ?? 0) > 0
        }
    }
    
    private func turnOffEditMode() {
        isEditModeOn = false
        
        navigationItem.rightBarButtonItem?.style = .plain
        navigationItem.rightBarButtonItem?.title = "Edit"
        nameTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        numberTextField.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        deleteButton.isHidden = true
        
        nameTextField.isEnabled = false
        numberTextField.isEnabled = false
        
        if let name = nameTextField.text,
           let number = numberTextField.text,
           let index = index {
            updateContactInfo(name: name, number: number, index: index)
        }
    
    }
    
    private func updateContactInfo(name: String, number: String, index: Int) {
       if var names = UserDefaults.standard.stringArray(forKey: "names"),
          var numbers = UserDefaults.standard.stringArray(forKey: "numbers") {
           names[index] = name
           numbers[index] = number
           UserDefaults.standard.set(names, forKey: "names")
           UserDefaults.standard.set(numbers, forKey: "numbers")
       }
        update?()
    }
    
    private func removeContact(atIndex index: Int) {
        if var names = UserDefaults.standard.stringArray(forKey: "names"),
           var numbers = UserDefaults.standard.stringArray(forKey: "numbers") {
            names.remove(at: index)
            numbers.remove(at: index)
            UserDefaults.standard.set(names, forKey: "names")
            UserDefaults.standard.set(numbers, forKey: "numbers")
        }
        update?()
    }
    
    @objc private func didTapDeleteButton() {
        if let index = index {
            removeContact(atIndex: index)
            navigationController?.popViewController(animated: true)
        }
    }
}
