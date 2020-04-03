//
//  BankTransferService.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 31/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class BankTransferService: BaseService {
    
    func getTransferMethod(forType: BankTransfer, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        request.tokenType = .customer
        
        if forType == .recipients {
             request.path = API.Path.getTransferRecipients
        } else { // Transfer Methods
            request.path = API.Path.getTransferMethods
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
