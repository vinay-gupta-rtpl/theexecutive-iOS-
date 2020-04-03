//
//  LoginViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

struct ApiError {
    var statusCode: Int?
    var message: String?
}

struct ValidationRule {
    var message: String?
}

class LoginViewModel: NSObject {
    // MARK: - view binding variables
    var emailID: String?
    var password: String?
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
    
    var fbUserInfo: NSDictionary = [:]
}

extension LoginViewModel {
    
    // MARK: - API Call
    func requestForCustomerLogin(success: @escaping((_ response: AnyObject) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        UserModel().doLogin(email: emailID!, password: password!, success: { (response) in
            if let guestCartCount = UserDefaults.standard.getGuestCartCount(), guestCartCount > 0 {
                if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                    self.mergeGuestCartToUser(guestCartId: guestCartToken, success: { (_) in
                        success(response)
                    }, failure: { (_) in
                        success(response)
                    })
                } else {
                    success(response)
                }
            } else {
                success(response)
            }
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    // MARK: - IsEmailAvailable API Call
    func requestForIsEmailAvailable(email: String, success: @escaping((_ response: Bool) -> Void), failure: @escaping((_ error: NSError) -> Void)) {
        UserModel().isEmailAvailable(email: email, success: { (response) in
            success(response)
        }, failure: { (error) in
            failure (error!)
        })
    }
    
    // MARK: - Social Login API Call
    func requestForSocialLogin(email: String, token: String, loginType: String, success: @escaping(() -> Void), failure: @escaping((_ error: NSError) -> Void)) {
        UserModel().requestForSocialLogin(email: email, token: token, loginType: loginType, success: {
            if let guestCartCount = UserDefaults.standard.getGuestCartCount(), guestCartCount > 0 {
                if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                    self.mergeGuestCartToUser(guestCartId: guestCartToken, success: { (_) in
                        success()
                    }, failure: { (_) in
                        success()
                    })
                } else {
                    success()
                }
            } else {
                success()
            }
        }, failure: { (error) in
            failure (error!)
        })
    }
    
    // MARK: - Validation
    func performValidation() -> Bool {
        if  emailID == nil || (emailID?.isEmpty)! {
            rule.message = AlertValidation.Empty.email
            return false
        }
        if !(emailID?.isValidEmail())! {
            rule.message = AlertValidation.Invalid.email
            return false
        }
        
        if password == nil || (password?.isEmpty)! {
            rule.message = AlertValidation.Empty.password
            return false
        }
        if !(password?.isValidPassword())! {
            rule.message = AlertValidation.Invalid.password
            return false
        } else {
            return true
        }
    }
    
    func setFBUserModal(resultDictionary: NSDictionary) -> RegisterViewModal {
        let viewModelRegister = RegisterViewModal()
        
        viewModelRegister.firstName = (resultDictionary.value(forKey: "first_name") as? String)!
        viewModelRegister.lastName = (resultDictionary.value(forKey: "last_name") as? String)!
        viewModelRegister.emailID = (resultDictionary.value(forKey: "email") as? String)!
        
        viewModelRegister.loginType = LoginType.social.rawValue
        return viewModelRegister
    }
    
    func mergeGuestCartToUser(guestCartId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().mergeGuestCartToUserCart(guestCartID: guestCartId, success: success, failure: failure)
    }
    
    func requestForGetCartToken(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().createRequestedUserCart(success: { (response) in
            if let registeredUserCartToken = response as? String {
                UserDefaults.standard.setUserCartToken(value: registeredUserCartToken)
                success(registeredUserCartToken as AnyObject)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func requestForGetCartCount(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getUserCartCount(success: { (response) in
            if let userCartCount = response as? Int {
                UserDefaults.standard.setUserCartCount(value: userCartCount)
                success(userCartCount as AnyObject)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
}
