//
//  ProfileService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Alamofire

class ProfileService: BaseService {
    func doLogin(email: String, password: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
//        guard let deviceId = UserDefaults.standard.getDeviceToken(), let fcmToken = UserDefaults.instance.getFCMRegistrationToken() else {
//            return
//        }
        
        // Because API is optional It can run without device Id and token too.
        let deviceId = UserDefaults.standard.getDeviceToken() ?? ""
        let fcmToken = UserDefaults.instance.getFCMRegistrationToken() ?? ""
        
        request.path = API.Path.login + "/?device_id=" + deviceId + "&device_type=ios" + "&registration_id=" + fcmToken
        request.parameters = ["username": email as AnyObject,
                              "password": password as AnyObject]
        self.callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func doForgotPassword(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .put
        request.path = API.Path.forgotPassword
        request.parameters = ["email": email as AnyObject,
                              "template": "email_reset" as AnyObject,
                              "websiteId": 1 as AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func logoutPerform(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.logout
//        guard let deviceId = UserDefaults.standard.getDeviceToken() else {
//            return
//        }
//        request.parameters = ["device_id": deviceId] as [String: AnyObject]
        
        request.parameters = ["device_id": UserDefaults.standard.getDeviceToken() ?? ""] as [String: AnyObject]
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func doRegister(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.register
        request.parameters = (parameters as? [String: AnyObject])!
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // Email Availability check
    func isEmailAvailable(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.isEmailAvailable
        request.parameters = ["customerEmail": email as AnyObject,
                              "websiteId": 1 as AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
   
    // Social Login API
    func requestForSocialLogin(email: String, token: String, loginType: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        
//        guard let deviceId = UserDefaults.standard.getDeviceToken(), let fcmToken = UserDefaults.instance.getFCMRegistrationToken() else {
//            return
//        }
        
        // Because API is optional It can run without device Id and token too.
        let deviceId = UserDefaults.standard.getDeviceToken() ?? ""
        let fcmToken = UserDefaults.instance.getFCMRegistrationToken() ?? ""
        
        request.path = API.Path.socialLogin + "/?device_id=" + deviceId + "&device_type=ios" + "&registration_id=" + fcmToken
        
        request.parameters = ["email": email as AnyObject,
                              "type": loginType as AnyObject,
                              "token": token as AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // get countries for Register screen
    func getCountries(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        request.path = API.Path.getCountries
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // get Cities for Register screen according to selected state/province
    func getCities(regionId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        request.path = API.Path.getCities + regionId
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // Subscription API
    func doSubscription(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.subscribe
        request.parameters = ["email": email as AnyObject]
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // Guest - Create Cart
    func createGuestCart(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.guestCart
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // Guest - Add to cart
    func requestForAddToCartGuest(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.addToCartForGuest + UserDefaults.standard.getGuestCartToken()! + "/items"
        request.tokenType = .admin
        request.parameters = (parameters as? [String: AnyObject])!
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // cart count for both guset and Registered User
    func getCartCount(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        if userType == .registeredUser {
            request.path = API.Path.registeredUserCartCount
            request.tokenType = .customer
        } else { // guset API path set
            if let guestToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.guestCartCount + guestToken + "/items/count"
                request.tokenType = .admin
            }
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // User - Create Cart
    func createRequestedUserCart(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.registeredUserCart
        request.tokenType = .customer
        
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // User - Add to cart
    func requestForAddToCartUser(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.addToCartForRegisteredUser
        request.tokenType = .customer
        request.parameters = (parameters as? [String: AnyObject])!
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // User - cart merge
    func mergeGuestCartToUserCart(guestCartID: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        request.path = API.Path.cartMergeAPI + "\(guestCartID)/"
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // User - account details
    func getMyAccountInfo(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = "/V1/customers/me"
        request.method = .get
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
