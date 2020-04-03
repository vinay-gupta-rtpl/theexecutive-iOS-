//
//  BindingTextField.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 23/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

let dateOfBirthTextFieldTagValue = 1000
let searchTextFieldDashboardTagValue = 1100
let searchTextFieldCatalogTagValue = 1200

class BindingTextfield: UITextField {
    var textChanged: (String) -> Void = { _ in }
    var donePressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setPadding()
//        if self.tag != dateOfBirthTextFieldTagValue {
//            addToolbarwithDoneButton(textField: self)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setPadding()
        addCustomAttributesToTextField(textField: self)
        
        // Adjust the height of tool bar according to customize Date picker in RegisterViewController. So For DatePicker hide the toolbar and add a custom tool bar for this.
        if self.tag != dateOfBirthTextFieldTagValue && self.tag != searchTextFieldDashboardTagValue && self.tag != searchTextFieldCatalogTagValue {
            addToolbarwithDoneButton(textField: self)
        }
    }

    func bind(callback :@escaping (String) -> Void) {
        self.textChanged = callback
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        self.textChanged(textField.text!)
    }
    
    // UITextField Padding And LookAndFeel
    func setPadding() {
        let paddingView: UIView
        
        paddingView = UIView.init(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: CGFloat(16.0), height: self.frame.height))
        self.leftViewMode = .always
        self.leftView = paddingView
    }
    
    // add tool baar with done button
    func addToolbarwithDoneButton (textField: UITextField) {
          let toolbar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(MainScreen.height - textField.frame.size.height - 50), width: CGFloat(MainScreen.width), height: CGFloat(50)))
        toolbar.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        toolbar.barStyle = UIBarStyle.default
        textField.textContentType = UITextContentType("")
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(actionDoneButton))]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    @objc func actionDoneButton() {
        endEditing(true)
    }
    
    // add textField animation on placeholder
    func addCustomAttributesToTextField(textField: UITextField) {
        // adding color to placeholder
        textField.placeHolderColor = ThemeColor.gray
        
        // adding bottom border
//        textField.addBottomBorder(width: 0.5, borderColor: ThemeColor.gray)
        
        // adding bottom border
        textField.setLeftPaddingPoints(amount: 5.0)
        
        // adding floating label textfield
        textField.setTextFieldWithFloatingLabel()
        
        // adding color to placeholder
        textField.floatingLabelTextColor = UIColor.black
        
        // adding x Padding to floating label
        textField.floatingLabelXPadding = 5.0
        
        // adding y Padding to floating label
        textField.floatingLabelYPadding = -10.0
        
    }
}
