//
//  NotificationServices.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 04/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation
import UIKit

class NotificationServices: BaseService {
    func getNotificationList(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.notificationList
        request.method = .post
        request.parameters = ["deviceId": UserDefaults.standard.getDeviceToken() ?? ""] as [String: AnyObject]
//        request.parameters = ["deviceId": "5af2e42c6982addcb03fb7b1008b424d8d1fd41d73ad6f5effd7917de7eb2a25"] as [String: AnyObject]
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func updateReadStatus(notificationId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.updateReadStatus
        request.method = .post
        request.parameters = ["notification_id": notificationId,
                              "device_id": UserDefaults.instance.getDeviceToken() != nil ?  UserDefaults.instance.getDeviceToken() : SystemConstant.deviceToken,
                              "customer_token": UserDefaults.standard.getUserToken()] as [String: AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
