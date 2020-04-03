//
//  ForgotPasswordViewModal.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 01/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ForgotPasswordViewModal: NSObject {
    // MARK: - view binding variables
    var emailID: String?
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension ForgotPasswordViewModal {
    
    // MARK: - API Call
    func requestForForgotPassword(success: @escaping((_ response: Bool) -> Void), failure: @escaping((_ error: NSError) -> Void)) {
        UserModel().doForgotPassword(email: emailID!, success: { (response) in
            success(response)
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error ?? NSError())
        })
    }
    
    // MARK: - Validation
    func performValidation() -> Bool {
        if emailID == nil || (emailID?.isEmpty)! {
            rule.message = AlertValidation.Empty.email.localized()
            return false
        }
        if !(emailID?.isValidEmail())! {
            rule.message = AlertValidation.Invalid.email.localized()
            return false
        } else {
            return true
        }
    }
}
