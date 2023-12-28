//
//  BorderColorTextFieldConstants.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 13.12.2023.
//

import UIKit

enum TextFieldBorder {
    case base
    case edit
    case error
}

extension TextFieldBorder {
    var color: CGColor {
        switch self {
        case .base:
            return CGColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        case .edit:
            return CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        case .error:
            return CGColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        }
    }
}
