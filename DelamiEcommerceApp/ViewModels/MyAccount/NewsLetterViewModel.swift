//
//  NewsLetterViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 23/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class NewsLetterViewModel: NSObject {
    var emailID: String?
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
    
}

extension NewsLetterViewModel {
    
    // MARK: - API Call
    func requestForSubscription(success: @escaping((_ response: String) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        UserModel().doSubscription(email: emailID!, success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
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
