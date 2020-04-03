//
//  DelamiTabBarViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 18/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class DelamiTabBarViewModel: NSObject {
    // create guest cart
    func requestForGuestCart(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().createGuestCart(success: { (response) in
            if let guestCartToken = response as? String {
                UserDefaults.standard.setGuestCartToken(value: guestCartToken)
                success(guestCartToken as AnyObject)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    // create customer cart
    func requestForGetCartToken(success:@escaping ((_ response: String) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().createRequestedUserCart(success: { (response) in
            if let registeredUserCartToken = response as? String {
                UserDefaults.standard.setUserCartToken(value: registeredUserCartToken)
                success(registeredUserCartToken)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func requestForGetCartCount(user: UserType, success:@escaping ((_ response: Int?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getCartCount(userType: user, success: { (response) in
             Loader.shared.hideLoading()
            if let cartCount = response as? Int {
                if user == .registeredUser {
                    UserDefaults.standard.setUserCartCount(value: cartCount)
                } else {
                    UserDefaults.standard.setGuestCartCount(value: cartCount)
                }
                success(Int(cartCount))
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func refreshCartToken(user: UserType, completion:@escaping ((_ isSucceed: Bool) -> Void)) {
        if user == .registeredUser {
            DelamiTabBarViewModel().requestForGetCartToken(success: { (_) in
                completion(true)
            }, failure: { (_) in
                completion(false)
            })
        } else {
            DelamiTabBarViewModel().requestForGuestCart(success: { (_) in
                completion(true)
            }, failure: { (_) in
                completion(false)
            })
        }
    }
}
