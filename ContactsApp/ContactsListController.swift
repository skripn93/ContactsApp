import Foundation


fileprivate let kCellIdentifierContact = "ContactCell"
fileprivate let kCellIdentifierHeader = "HeaderCell"

fileprivate let kSegueEditContactIdentifier = "kSegueContactEdit"

class ContactsListController:UIViewController {
    let fetchProvider = ContactsFetchProvider()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
    }
    
    func commonInit() {
        
        self.tableView.allowsSelectionDuringEditing = false
        
        DispatchQueue.main.async {
            self.fetchProvider.fetchContacts(search: "", delegate:self)
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Fetch Helpers -
    
    public func contacts(forSection section:Int) -> [Contacts] {
        guard let sections = fetchProvider.fetchResultsController?.sections else {
            return [Contacts]()
        }
        return sections[section].objects as! [Contacts]
    }
    
    public func contact(forIndexPath indexPath:IndexPath) -> Contacts! {
        return fetchProvider.fetchResultsController?.object(at: indexPath) as? Contacts
    }
    
    
    // MARK: - Cells Helpers -
    
    public func contactCell(atIndexPath indexPath:IndexPath) -> ContactsListContactCell {
        let cell:ContactsListContactCell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierContact) as! ContactsListContactCell
        if let contact = self.contact(forIndexPath: indexPath) {
            cell.configure(contact: contact)
        }
        return cell
    }
    
    
    // MARK: - UI Actions -
    
    @IBAction func addContactDidTap(_ sender: Any) {
        
    }
    
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueEditContactIdentifier {
            if let navController = segue.destination as? UINavigationController {
                if let controller = navController.viewControllers.first as? ContactEditViewController {
                    if let contact:Contacts = sender as? Contacts {
                        controller.contactID = contact.contactID
                    }
                }
            }
        }
    }
}


extension ContactsListController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchProvider.fetchResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchProvider.fetchResultsController?.sections else {
            return 0
        }
        return sections[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.contactCell(atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = self.fetchProvider.fetchResultsController?.sections?[section]
        return sectionInfo?.name
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ContactsListController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactsListContactCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = self.contact(forIndexPath: indexPath)
        performSegue(withIdentifier: kSegueEditContactIdentifier, sender: contact)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let contact = self.contact(forIndexPath: indexPath)
            
            let alertController = UIAlertController.init(title: "Are you sure to delete contact?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction.init(title: "Delete", style: UIAlertActionStyle.default, handler: { (alertAction) in
                if let contactID = contact?.contactID {
                    ContactsManageProvider.shared.delete(contactID: contactID)
                }
                alertController.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }
}


extension ContactsListController:NSFetchedResultsControllerDelegate {
   
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var letters = [String]()
        
        if let sections = self.fetchProvider.fetchResultsController?.sections {
            for sectionInfo in sections {
                letters.append(sectionInfo.name)
                // Made mistakes with tap to scroll
                //letters.append("•")
            }
        }
        
        return letters
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                guard let cell:ContactsListContactCell = tableView.cellForRow(at: indexPath as IndexPath) as? ContactsListContactCell else { break }
                if let contact = controller.object(at: indexPath as IndexPath) as? Contacts {
                    cell.configure(contact: contact)
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
