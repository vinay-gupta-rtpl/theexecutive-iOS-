//
//  String+Validation.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 01/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegex: NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func isValidContactNo() -> Bool {
        let contactRegex: NSString = "^[0-9]{6,16}$"
        let contactTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", contactRegex)
        return contactTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        //Minimum 8 characters in length with atleast one Special character  and one digit
//        let contactRegex: NSString = "^(?=.*?[0-9])(?=.*?[#?!@$%^&*+=-]).{8,}$"
        
        // Minimum 8 characters in length with atleast one alphabet and a number - requirement changed
        let contactRegex: NSString = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$"

        let contactTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", contactRegex)
        return (contactTest.evaluate(with: self))
    }
    
    func isValidMobileNumber() -> Bool {
        if self.count >= AlertValidation.Length.phoneNumberMinimum && self.count <= AlertValidation.Length.phoneNumberMaximum {
            return true
        } else {
            return false
        }
    }

    func encode() -> String {
        let variable = self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        return variable
    }
}
