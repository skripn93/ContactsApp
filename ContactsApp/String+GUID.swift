//
//  Contacts+GUID.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation


extension String {
    
    static func generateGUID() -> String {
        return UUID().uuidString
    }
    
    subscript (i: Int) -> String {
        return String.init(self[index(startIndex, offsetBy: i)])
    }
    
}
