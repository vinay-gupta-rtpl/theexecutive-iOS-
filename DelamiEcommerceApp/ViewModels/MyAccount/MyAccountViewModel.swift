//
//  MyAccountViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 22/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class MyAccountViewModel: NSObject {

    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension MyAccountViewModel {
    
    func requestForMyInfo(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        MyInformationModel().getMyInfo(success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func requestForUnreadNotification(success: @escaping((_ response: Int?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        MyInformationModel().requestForUnreadNotification(success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
}
