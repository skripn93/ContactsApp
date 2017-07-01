//
//  ContactEditModel.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation


enum ContactEditFields: String {
    case firstName = "firstName",
    lastName = "lastName",
    phoneNumber = "phoneNumber",
    zipCode = "zipCode",
    streetAddress1 = "streetAddress1",
    streetAddress2 = "streetAddress2",
    city = "city",
    state = "state",
    contactID = "contactID"
}

class ContactEditModel:NSObject {
    
    var firstName:String!
    var lastName:String!
    var phoneNumber:String!
    var zipCode:String!
    var streetAddress1:String!
    var streetAddress2:String!
    var city:String!
    var state:String!
    var contactID:String!
    var formattedName:String {
        get {
            var nameItems = [String]()
            if let _firstName = self.firstName {
                if (_firstName.characters.count > 0) {
                    nameItems.append(_firstName)
                }
            }
            if let _lastName = self.lastName {
                if (_lastName.characters.count > 0) {
                    nameItems.append(_lastName)
                }
            }
            return nameItems.joined(separator: " ")
        }
    }
    
    init(withContactID contactID:String) {
        super.init()
        self.update(contactID: contactID)
    }
    
    private func update(contactID:String) {
        let contact = ContactsFetchProvider.shared.fetchContact(byID: contactID, inContext:DSCoreData.shared.readContext)
        if (contact != nil) {
            for field in iterateEnum(ContactEditFields.self) {
                if let value = contact?.value(forKey: field.rawValue) {
                    self.set(field: field, value: value)
                }
            }
        }
    }
    
    public func value(forField field:ContactEditFields) -> Any {
        return self.value(forKey: field.rawValue) ?? ""
    }
    
    public func set(field:ContactEditFields, value:Any) {
        self.setValue(value, forKey: field.rawValue)
    }
    
    public func save() -> ContactsManagerResult {
        if (self.contactID != nil && self.contactID.characters.count > 0) {
            return ContactsManageProvider.shared.updateModel(fromInfo: self.toDictionary())
        } else {
            return ContactsManageProvider.shared.createModel(fromInfo: self.toDictionary())
        }
    }
    
    private func toDictionary() -> [String:Any] {
        var fields = [String:Any]()
        
        for field in iterateEnum(ContactEditFields.self) {
            if let value:String = self.value(forField: field) as? String {
                fields[field.rawValue] = value
            }
        }
        
        return fields
    }
    
    private func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    
    // MARK: - Static Helpers -
    
    // TODO: Phone formatter
    public static func formatPhone(phone:String) -> String {
        let result = String(phone.characters.filter { "01234567890+()-".characters.contains($0) })
        
        return result
    }
    
    /**
     Example of format ZIP code which depends on country. This example only for US zip formats.
     */
    public static func formatZip(zipCode:String) -> String {
        var result = String(zipCode.characters.filter { "01234567890".characters.contains($0) })
        
        // ZIP max length = 5 + 4 = 9
        if (result.characters.count > 9) {
            result = result.substring(to: result.index(result.startIndex, offsetBy: 9))
        }
        
        if (result.characters.count >= 6) {
            result.insert(Character.init("-"), at: result.index(result.startIndex, offsetBy: 5))
        }
        return result
    }
    
    
}
