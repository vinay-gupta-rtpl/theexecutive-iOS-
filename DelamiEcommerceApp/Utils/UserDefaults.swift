//
//  UserDefaults.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 08/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    // Make singleton object.
    static let instance = UserDefaults()
    
    // MARK: - Set/Get Store code of store
    func setStoreCode(value: String?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.storeId)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.storeId)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getStoreCode() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.storeId) as? String
    }
    
    // MARK: - Set/Get Store code of store
    func setStoreWebsiteId(value: Int?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.storeWebsiteId)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.storeWebsiteId)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getStoreWebsiteId() -> Int? {
        return ((UserDefaults.standard.value(forKey: UserDefault.storeWebsiteId) as? Int) ?? 1)
    }
    
    // MARK: - Set/Get Store code of store
    func setStoreId(value: Int?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.selectedStoreIdentifier)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.selectedStoreIdentifier)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getStoreId() -> Int? {
        return ((UserDefaults.standard.value(forKey: UserDefault.selectedStoreIdentifier) as? Int) ?? 1)
    }
    
    // MARK: - Set/Get user token
    func setUserToken(value: String?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.userToken)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.userToken)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getUserToken() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.userToken) as? String
    }
    
    // MARK: - Create Guest Cart
    func setGuestCartToken(value: String?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.guestCartToken)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.guestCartToken)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getGuestCartToken() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.guestCartToken) as? String
    }
    
    // MARK: - Create Registered User Cart
    func setUserCartToken(value: String?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.userCartToken)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.userCartToken)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getUserCartToken() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.userCartToken) as? String
    }
    
    // MARK: - User cart Count
    func setUserCartCount(value: Int?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.registeredUserCartCount)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.registeredUserCartCount)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getUserCartCount() -> Int? {
        return UserDefaults.standard.value(forKey: UserDefault.registeredUserCartCount) as? Int
    }
    
    // MARK: - Guest cart Count
    func setGuestCartCount(value: Int?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.guestCartCount)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.guestCartCount)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getGuestCartCount() -> Int? {
        return UserDefaults.standard.value(forKey: UserDefault.guestCartCount) as? Int
    }
    
    // MARK: - Set/Get user Email
    func setUserEmail(value: String?) {
        if value != nil {
            UserDefaults.standard.set(value, forKey: UserDefault.email)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.email)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getUserEmail() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.email) as? String
    }
    
    // MARK: - Set/Get Device Token
    func setDeviceToken(value: String?) {
        if let val = value {
            UserDefaults.standard.set(val, forKey: UserDefault.deviceToken)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.deviceToken)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getDeviceToken() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.deviceToken) as? String
    }
    
    // MARK: - Set/Get FCM Token
    func setFCMRegistrationToken(value: String?) {
        if let val = value {
            UserDefaults.standard.set(val, forKey: UserDefault.fcmRegisterationToken)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefault.fcmRegisterationToken)
        }
        UserDefaults.standard.synchronize()
    }
    
    func getFCMRegistrationToken() -> String? {
        return UserDefaults.standard.value(forKey: UserDefault.fcmRegisterationToken) as? String
    }
    
    // MARK: - Set/Get Notification ID array
    func setNotificationIds(array: NSArray?) {
        if let notificationIdArray = array {
            if notificationIdArray.count > 0 {
                UserDefaults.standard.set(notificationIdArray, forKey: UserDefault.notificationIdArray)
            } else {
                UserDefaults.standard.removeObject(forKey: UserDefault.notificationIdArray)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    func getNotificationIds() -> NSArray? {
        return UserDefaults.standard.value(forKey: UserDefault.notificationIdArray) as? NSArray
    }
    
    // clear guest related data
    func clearGuestDefaultData() {
        setGuestCartCount(value: nil)
        setGuestCartToken(value: nil)
    }
    
    // clear registered user related Data
    func clearUserDefaultData() {
        //        setIsFirstLogin(value: nil)
        setUserToken(value: nil)
        setUserCartCount(value: nil)
        setUserCartToken(value: nil)
    }
}
