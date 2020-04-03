//
//  MyInformationViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class MyInformationViewModel: NSObject {
    var phoneCode: String?
    var phoneNumber: String?
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension MyInformationViewModel {
    
    // MARK: - Validation
    func performValidation() -> Bool {
        if phoneNumber == nil || (phoneNumber?.isEmpty)! {
            rule.message = AlertValidation.Empty.mobileNumber.localized()
            return false
        } else {
            return true
        }
    }
    
    func requestForMyInfo(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        MyInformationModel().getMyInfo(success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func requestForEditPhoneNumberInAddress(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        var infoModel = MyInformationModel()
        infoModel.editPhoneNumberInAddress(addressVM: self, success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
}
