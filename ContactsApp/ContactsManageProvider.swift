import Foundation
import CoreData
import MagicalRecord

class ContactsManagerResult {
    var errors:[String:Any]!
    var contactID:String!
    
    init(contactID:String?, errors:[String:Any]?) {
        self.errors = errors
        self.contactID = contactID
    }
}

class ContactsManageProvider:NSObject {
    static let shared = ContactsManageProvider()
    
    
    override init() {
        super.init()
        
        //Contacts.mr_deleteAll(matching: NSPredicate.init(value: true))
        importFromJSON()
    }
    
    
    
    // MARK: - JSON import -
    private func importFromJSON() {
        let path = Bundle.main.url(forResource: "ContactsJSON", withExtension: "json")
        
        do {
            if let _path = path {
                let dataJson = try Data.init(contentsOf: _path)
                let contactsObjects = self.parseJSON(dataJson: dataJson)
                
                for contactObject in contactsObjects {
                   let _ = createModel(fromInfo: contactObject)
                }
            }
        } catch {
            
        }
        
    }
    
    private func parseJSON(dataJson:Data?) -> [[String:Any]] {
        do {
            if let data = dataJson,
                let json = try JSONSerialization.jsonObject(with: data) as? [[String:Any]] {
                return json
            } else {
                return [[String:Any]]()
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return [[String:Any]]()
        }
    }
    
    
    
    //MARK: - Public functions -
    
    /**
     Create new Contact
     @param Dictionary with model fields and their values, like ["contactID":"value", ...].
     @return ContactsManagerResult
     */
    public func createModel(fromInfo info:[String:Any]) -> ContactsManagerResult {
        let context = DSCoreData.shared.writeContext
        
        let phoneNumber = info["phoneNumber"] ?? ""
        let contactToCheck = ContactsFetchProvider.shared.fetchContact(byPhone: phoneNumber as! String)
        if (contactToCheck != nil) {
            return ContactsManagerResult.init(contactID: nil, errors: [
                "common":"There is contact with this phone."
            ])
        }
        
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Contacts",
                                       in: context)!
        let contact:Contacts = NSManagedObject(entity: entity,
                                     insertInto: context) as! Contacts
        
        for (fieldName, value) in info {
            contact.setValue(value, forKey: fieldName)
        }
        contact.setValue(String.generateGUID(), forKey: "contactID")
        if let firstName = contact.firstName {
            if (firstName.characters.count > 0) {
                contact.setValue(firstName[0].capitalized, forKey: "firstNameLetter")
            }
        }
        if let lastName = contact.lastName {
            if (lastName.characters.count > 0) {
                contact.setValue(lastName[0].capitalized, forKey: "lastNameLetter")
            }
        }
        
        let errors = contact.validate()
        if (errors.count > 0) {
            
            contact.mr_deleteEntity()
            return ContactsManagerResult.init(contactID: nil, errors: errors)
        }
        DSCoreData.shared.saveWriteContext(withCompletion: nil)
        return ContactsManagerResult.init(contactID: contact.contactID ?? "", errors: nil)
    }
    
    /**
     Update existing Contact
     @param Dictionary with model fields and their values, like ["contactID":"value", ...].
     @return ContactsManagerResult
     */
    public func updateModel(fromInfo info:[String:Any]) -> ContactsManagerResult {
        let contactID = (info["contactID"] as? String) ?? ""
        if (contactID.characters.count == 0) {
            return ContactsManagerResult.init(contactID: nil, errors: [
                "common": "Unkwnown error"
            ]);
        }
        
        guard let contact = ContactsFetchProvider.shared.fetchContact(byID: contactID) else {
            return ContactsManagerResult.init(contactID: nil, errors: [
                "common": "Unkwnown error"
            ]);
        }
        for (fieldName, value) in info {
            contact.setValue(value, forKeyPath: fieldName)
        }
        
        if let firstName = contact.firstName {
            if (firstName.characters.count > 0) {
                contact.setValue(firstName[0].capitalized, forKey: "firstNameLetter")
            }
        }
        if let lastName = contact.lastName {
            if (lastName.characters.count > 0) {
                contact.setValue(lastName[0].capitalized, forKey: "lastNameLetter")
            }
        }
        
        
        let errors = contact.validate()
        if (errors.count == 0) {
            DSCoreData.shared.saveWriteContext(withCompletion: nil)
        }
        DSCoreData.shared.readContext.refresh(contact, mergeChanges: false)
        return ContactsManagerResult.init(contactID: contactID, errors: errors);
    }
    
    public func delete(contactID:String) {
        let contact = ContactsFetchProvider.shared.fetchContact(byID: contactID)
        if (contact != nil) {
            contact?.mr_deleteEntity()
            DSCoreData.shared.saveWriteContext(withCompletion: nil)
        }
    }
    
}
