//
//  ContactEditViewController.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation

class EditField {
    var identifier:ContactEditFields!
    var placeholder:String!
    
    init(identifier:ContactEditFields, placeholder:String) {
        self.identifier = identifier
        self.placeholder = placeholder
    }
    
}

fileprivate let kCellTextIdentifier = "TextCell"

// Used UITableViewController to automatically move text cells above keyboard
class ContactEditViewController:UITableViewController {
    public var contactID:String?
    var contactModel:ContactEditModel!

    let fields:[EditField] = [
        EditField.init(identifier: ContactEditFields.firstName, placeholder: "First name"),
        EditField.init(identifier: ContactEditFields.lastName, placeholder: "Last name"),
        EditField.init(identifier: ContactEditFields.phoneNumber, placeholder: "Phone"),
        EditField.init(identifier: ContactEditFields.city, placeholder: "City"),
        EditField.init(identifier: ContactEditFields.state, placeholder: "State"),
        EditField.init(identifier: ContactEditFields.streetAddress1, placeholder: "Street address 1"),
        EditField.init(identifier: ContactEditFields.streetAddress2, placeholder: "Street address 2"),
        EditField.init(identifier: ContactEditFields.zipCode, placeholder: "Zip code")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactModel = ContactEditModel.init(withContactID: contactID ?? "")
        
        if (contactModel.formattedName.characters.count > 0) {
            title = contactModel.formattedName
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    // MARK: - UI Actions -
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        let result = contactModel.save()
        
        if (result.errors != nil && result.errors.count > 0) {
            var errorTexts = [String]()
            for (_, value) in result.errors {
                errorTexts.append(value as! String)
            }
            
            let alertController = UIAlertController.init(title: "Errors", message: errorTexts.joined(separator: "\n"), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction.init(title: "Cloase", style: UIAlertActionStyle.cancel, handler: { (alertAction) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - UITableViewDataSource -
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        let value:String = contactModel.value(forField: field.identifier) as! String
        
        let cell:ContactEditTextCell = self.tableView.dequeueReusableCell(withIdentifier: kCellTextIdentifier) as! ContactEditTextCell
        
        cell.configure(withEditField: field, value: value)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    // MARK: - UITableViewDelegate -
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactEditTextCell.height()
    }
}

extension ContactEditViewController:ContactEditTextCellDelegate {
    func contactEditCell(didChangeValue newValue: Any, field: ContactEditFields) {
        contactModel.set(field: field, value: newValue)
    }
}

