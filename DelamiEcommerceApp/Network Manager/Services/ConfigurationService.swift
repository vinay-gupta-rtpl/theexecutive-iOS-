//
//  ConfigurationService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 12/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ConfigurationService: BaseService {
    // MARK: - get app version and maintenance related settings
    func getConfiguration(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.configuration
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // MARK: - get application supported languages
    func getLanguges(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.store
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getHomePromotions(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.homePromotions
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func registerGuestDevice(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.registerGuestFornotification

        guard let deviceId = UserDefaults.standard.getDeviceToken(), let fcmToken = UserDefaults.instance.getFCMRegistrationToken() else {
            return
        }
        
        request.parameters = ["device_id": deviceId,
                              "device_type": "ios",
                              "registration_id": fcmToken] as? [String: AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
