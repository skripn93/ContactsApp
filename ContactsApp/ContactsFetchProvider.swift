import Foundation
import CoreData
import MagicalRecord

enum GrorupLetterField: Int {
    case firstName = 0, lastName = 1
}

class ContactsFetchProvider {
    static let shared = ContactsFetchProvider()
    
    var groupLetterField = GrorupLetterField.firstName
    
    public var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        get {
            return _fetchResultsController
        }
    }
    
    private var _fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
    
    private func fieldForGroup(group:GrorupLetterField) -> String {
        switch group {
        case .firstName:
            return "firstNameLetter"
        case .lastName:
            return "lastNameLetter"
        }
    }
    
    public func fetchContacts(search:String, delegate:UIViewController) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Contacts")
        
        if (search.characters.count > 0) {
            fetchRequest.predicate = NSPredicate.init(format: "firstName CONTAINS[d] %@ OR lastName CONTAINS[d] %@", search, search)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: fieldForGroup(group: groupLetterField), ascending: true)]
        
        _fetchResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: DSCoreData.shared.readContext, sectionNameKeyPath: fieldForGroup(group: groupLetterField), cacheName: nil)
        
        // Need to set delegate before performFetch()
        _fetchResultsController?.delegate = delegate as? NSFetchedResultsControllerDelegate
        try? _fetchResultsController?.performFetch()
    }
    
    public func fetchContact(byPhone phone:String) -> Contacts! {
        return Contacts.mr_findFirst(byAttribute: "phoneNumber", withValue: phone, in: DSCoreData.shared.readContext)
    }
    
    public func fetchContact(byID contactID:String) -> Contacts! {
        return Contacts.mr_findFirst(byAttribute: "contactID", withValue: contactID, in: DSCoreData.shared.readContext)
    }
    
}
