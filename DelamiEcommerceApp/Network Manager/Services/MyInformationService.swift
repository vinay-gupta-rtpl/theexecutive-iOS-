//
//  MyInformationService.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Alamofire

class MyInformationService: BaseService {
    func getConfiguration(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.myInformation
        request.method = .get
        request.tokenType = .customer
        
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func changeInAddress(param: MyInformationModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.myInformation
        request.method = .put
        request.tokenType = .customer
        do {
          let jsonData = try JSONEncoder().encode(param)
            let param = try (JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject])!
            request.parameters = ["customer": param as AnyObject]

        } catch {
           debugPrint("JSON serialization error:")
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }

    func changeInPassword(currentPassword: String, newPassword: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.changePassword
        request.method = .put
        request.tokenType = .customer
        request.parameters = [
            "currentPassword": currentPassword as AnyObject,
            "newPassword": newPassword as AnyObject
        ]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // bank transfer
    func bankTransfer(paramModel: BankTransferViewModel, fileName: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.bankTransfer
        request.method = .post
        request.tokenType = .customer
        request.parameters = ["name": paramModel.firstName + " " + paramModel.lastName,
                              "email_submitter": paramModel.emailID,
                              "orderid": paramModel.orderNumber,
                              "bank_name": paramModel.bankNumber,
                              "holder_account": paramModel.holderAccountNumber,
                              "amount": paramModel.transferAmount,
                              "recipient": paramModel.bankRecipient,
                              "method": paramModel.transferMethod,
                              "date": paramModel.transferDate] as [String: AnyObject]
//                              "attachment": paramModel.attachmentImage] as [String: AnyObject]
        
        // Creating image dictionary
        let imageDict = ["attachment": paramModel.attachmentImage]
//        let attachedFileName = paramModel.orderNumber + "_" + paramModel.transferDate
        
        callWebServiceAlamofireForAttachment(imageDict: (imageDict as? [String: Data])!, fileName: fileName, alamoReq: request, success: success, failure: failure)
    }
    
    func getUnreadNotificationCount(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.unreadNotificationCount
        request.method = .post
        request.tokenType = .customer
        request.parameters = ["deviceId": UserDefaults.instance.getDeviceToken() ?? ""] as? [String: AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }

}
