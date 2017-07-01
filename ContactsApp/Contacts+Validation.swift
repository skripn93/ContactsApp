//
//  Contacts+Validation.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation

extension Contacts {
    
    
    /**
     Validate object fields
     @return Dictionary with validation error, like ["contactID":"Unknown error", ...].
     */
    func validate() -> [String:Any] {
        var errors = [String:Any]()
      
        if (contactID == nil || contactID?.characters.count == 0) {
            errors["contactID"] = "contactID is required field."
        }
        if (phoneNumber == nil || phoneNumber?.characters.count == 0) {
            errors["phoneNumber"] = "Phone is required field."
        }
        if (firstName == nil || firstName?.characters.count == 0) {
            errors["firstName"] = "First name is required field."
        }
        if (lastName == nil || lastName?.characters.count == 0) {
            errors["lastName"] = "Last name is required field."
        }
        
        return errors
    }
    
}
