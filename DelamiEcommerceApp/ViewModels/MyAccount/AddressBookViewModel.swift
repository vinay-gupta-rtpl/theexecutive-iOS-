//
//  AddressBookViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class AddressBookViewModel: NSObject {
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension AddressBookViewModel {
    
    func requestForMyInfo(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        MyInformationModel().getMyInfo(success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func requestForChangeAddress(address: inout InfoAddress, changeType: AddressChangeType, success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        
        MyInformationModel().changeInAddress(address: &address, changeType: changeType, success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
}
