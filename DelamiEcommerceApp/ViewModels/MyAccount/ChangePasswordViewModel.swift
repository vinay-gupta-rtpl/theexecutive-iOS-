//
//  ChangePasswordViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/9/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class ChangePasswordViewModel: NSObject {
    var currentpassword: String = ""
    var newPassword: String = ""
    var confirmNewPass: String = ""

    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()

}
extension ChangePasswordViewModel {

    func performValidation() -> Bool {
        if  currentpassword.isEmpty {
            rule.message = AlertValidation.Empty.currentPassword.localized()
            return false
        }
        if  newPassword.isEmpty {
            rule.message = AlertValidation.Empty.newPassword.localized()
            return false
        }
        if confirmNewPass.isEmpty {
            rule.message = AlertValidation.Empty.confirmNewPassword.localized()
            return false
        }
        if !(newPassword.isValidPassword()) {
            rule.message = AlertValidation.Invalid.password.localized()
            return false
        }
        if !(newPassword == confirmNewPass) {
            rule.message = AlertValidation.Invalid.passwordAndConfirmPasswordDiffer.localized()
            return false
        } else {
            return true
        }
    }
}

extension ChangePasswordViewModel {
    func requestForChangePassword(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().changePassword(currentPassword: currentpassword, newPassword: newPassword, success: { (response) in
                if let jsonData = response as? Bool {
                    if jsonData {
                       success(response)
                    }
                } else {
                    debugPrint("failure: jsonData is not available")
                    failure(nil)
                }
            }, failure: failure)
    }
}
