import Foundation
import CoreData
import MagicalRecord


class DSCoreData:NSObject {
    static let shared = DSCoreData()
    
    private var masterContext:NSManagedObjectContext!
    var readContext:NSManagedObjectContext {
        get {
            return NSManagedObjectContext.mr_default()
        }
    }
    var writeContext:NSManagedObjectContext {
        get {
            return NSManagedObjectContext.mr_rootSaving()
        }
    }
    
    override init() {
        super.init()
        
        initialize()
    }
    
    public func initialize() {
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "ContactsApp.sqlite")
    }
    
    public func saveWriteContext(withCompletion completionBlock:MRSaveCompletionHandler?) {
        writeContext.mr_saveToPersistentStore { (completion, error) in
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
    }
    
    public func saveReadContext(withCompletion completionBlock:MRSaveCompletionHandler?) {
        print(DSCoreData.shared.readContext)
        
        readContext.mr_save(options: [MRSaveOptions.parentContexts, MRSaveOptions.synchronously], completion: { (saved, error) in
            if let _completion = completionBlock {
                _completion(saved, error)
            }
        })
    }
}
