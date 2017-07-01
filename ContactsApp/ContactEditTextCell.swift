//
//  ContactEditTextCell.swift
//  ContactsApp
//
//  Created by Denis Skripnichenko on 01/07/2017.
//  Copyright © 2017 Denis Skripnichenko. All rights reserved.
//

import Foundation

protocol ContactEditTextCellDelegate {
    func contactEditCell(didChangeValue newValue:Any, field:ContactEditFields)
}

class ContactEditTextCell:UITableViewCell {
    var field:ContactEditFields!
    var delegate:ContactEditTextCellDelegate!
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var clearButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    private func commonInit() {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        clearButton.isHidden = true
        textField.addTarget(self, action: #selector(textDidChange(textField:)), for: UIControlEvents.editingChanged)
        textField.delegate = self
    }
    
    func configure(withEditField editField:EditField, value:String) {
        self.field = editField.identifier
        self.textField.text = value
        self.textField.placeholder = editField.placeholder
        
        if self.field == ContactEditFields.zipCode {
            textField.keyboardType = UIKeyboardType.numberPad
        }
        if self.field == ContactEditFields.phoneNumber {
            textField.keyboardType = UIKeyboardType.phonePad
        }
    }
    
    func autoFormatField() {
        if self.field == ContactEditFields.zipCode {
            textField.text = ContactEditModel.formatZip(zipCode: textField.text ?? "")
        }
        if self.field == ContactEditFields.phoneNumber {
            textField.text = ContactEditModel.formatPhone(phone: textField.text ?? "")
        }
    }
    
    
    // MARK: - Static -
    
    static func height() -> CGFloat {
        return 44.0
    }
    
    
    // MARK: - UI Actions -
    
    @IBAction func clearButtonDidTap(_ sender: Any) {
        textField.text = ""
        if let _delegate = delegate {
            _delegate.contactEditCell(didChangeValue: "", field: field)
        }
    }
    
    
    // MARK: Handlers
    
    func textDidChange(textField:UITextField) {
        autoFormatField()
        if let text = textField.text {
            self.clearButton.isHidden = text.characters.count == 0
        }
        if let _delegate = delegate {
            _delegate.contactEditCell(didChangeValue: textField.text ?? "", field: field)
        }
    }
    
}

extension ContactEditTextCell:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            self.clearButton.isHidden = text.characters.count == 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.clearButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
