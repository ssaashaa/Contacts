//
//  PaddedTextField.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 30.09.2023.
//

import UIKit

final class PaddedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
