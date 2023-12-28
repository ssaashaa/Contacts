//
//  ContactTableViewCell.swift
//  Contacts
//
//  Created by Sasha Stryapkov on 13.12.2023.
//

import UIKit

final class ContactTableViewCell: UITableViewCell {    
    @IBOutlet private weak var contactNameLabel: UILabel!
    
    func setCell(_ fullName: String) {
        contactNameLabel.text = fullName
    }
}
