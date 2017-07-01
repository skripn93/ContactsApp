//
//  ContactsListContactCell.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation


class ContactsListContactCell:UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    public func configure(contact:Contacts) {
        var nameItems = [String]()
        
        if let _firstName = contact.firstName {
            if (_firstName.characters.count > 0) {
                nameItems.append(_firstName)
            }
        }
        if let _lastName = contact.lastName {
            if (_lastName.characters.count > 0) {
                nameItems.append(_lastName)
            }
        }
        
        nameLabel.text = nameItems.joined(separator: " ")
        
        if let _phone = contact.phoneNumber {
            phoneLabel.text = _phone
        }
    }
    
    
    public static func height()-> CGFloat {
        return 63.0
    }
}
