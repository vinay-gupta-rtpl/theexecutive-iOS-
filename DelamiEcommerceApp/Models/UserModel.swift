//
//  UserModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 07/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

struct UserModel: Decodable {
    var emailId: String?
    var firstName: String?
    var lastName: String?
    var age: Int? = 0
    var gender: String = "male"
}

extension UserModel {
    func doLogin(email: String, password: String, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().doLogin(email: email, password: password, success: { (response) in
            if let customerToken = response as? String {
                print(customerToken)
                UserDefaults.standard.setUserToken(value: customerToken)
                UserDefaults.standard.setUserEmail(value: email)
                success(customerToken as AnyObject)
            } else { 
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func doForgotPassword(email: String, success:@escaping ((_ response: Bool) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().doForgotPassword(email: email, success: { (response) in
            if let mailSent = response {
                success((mailSent as? Bool)!)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func doRegister(registerVM: RegisterViewModal?, success:@escaping ((_ response: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        let param = self.prepareRegisterRequestParam(registerVM)
        ConnectionManager().doRegister(parameters: param, success: { (response) in
            success(response)
        }, failure: failure)
    }
    
    func isEmailAvailable(email: String, success:@escaping ((_ response: Bool) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().isEmailAvailable(email: email, success: { (response) in
            if let isEmailAvailable = response as? Bool {
                success(isEmailAvailable)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func requestForSocialLogin(email: String, token: String, loginType: String, success:@escaping (() -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().requestForSocialLogin(email: email, token: token, loginType: loginType, success: { (response) in
            if let customerToken = response as? String {
                UserDefaults.standard.setUserToken(value: customerToken)
                UserDefaults.standard.setUserEmail(value: email)
                success()
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func doSubscription(email: String, success:@escaping ((_ response: String) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().doSubscription(email: email, success: { (response) in
            if let subscriptionStatus = response as? String {
                success(subscriptionStatus)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func logoutPerform(success:@escaping ((_ response: Bool) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().logoutPerform(success: { (response) in
            if let succeed = response {
                success((succeed as? Bool)!)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
}

extension UserModel {
    fileprivate func prepareRegisterRequestParam(_ registerVM: RegisterViewModal?) -> AnyObject? {
        var paramDict: [String: AnyObject?] = [:]
        
        var customerDict: [String: Any?] = [:]
        var isSubscribedDict: [String: Any?] = [:]
        var addressDict: [String: Any?] = [:]
        var regionDict: [String: Any?] = [:]
        let street = NSMutableArray()
        let addressArray = NSMutableArray()
        
        isSubscribedDict["is_subscribed"] = registerVM?.isSubscribed ?? false
        customerDict["group_id"] = 1
        customerDict["confirmation"] = registerVM?.loginType ?? "" // if social login then "social" else in case of normal login ""
        
        customerDict["email"] = registerVM?.emailID ?? ""
        customerDict["firstname"] = registerVM?.firstName ?? ""
        customerDict["lastname"] = registerVM?.lastName ?? ""
        customerDict["Prefix"] = "Mr."
        
//        customerDict["dob"] = registerVM?.birthDate ?? ""
//        customerDict["gender"] = registerVM?.gender ?? 1
        if let genderValue =  registerVM?.gender {
             customerDict["gender"] = genderValue
        }

        if let birthDate = registerVM?.birthDate {
            customerDict["dob"] = birthDate
        }
        
        customerDict["store_id"] = UserDefaults.standard.getStoreId() ?? 1
        customerDict["website_id"] = UserDefaults.standard.getStoreWebsiteId() ?? 1
        customerDict["extension_attributes"] = isSubscribedDict
        
        regionDict["region_code"] = registerVM?.selectedRegion?.code ?? ""
        regionDict["region_id"] = registerVM?.selectedRegion?.regionId ?? ""
        regionDict["region"] = registerVM?.selectedRegion?.name ?? ""
        
        street.add(registerVM?.streetAddressLine1 ?? "")
        street.add(registerVM?.streetAddressLine2 ?? "")
        
        addressDict["region"] = regionDict as AnyObject
        addressDict["region_id"] = registerVM?.selectedRegion?.regionId ?? ""
        addressDict["country_id"] = registerVM?.selectedCountryId ?? ""
        addressDict["street"] = street
        let mobileCode = (registerVM?.mobileCode ?? "")
        
        addressDict["telephone"] = mobileCode + "-" + (registerVM?.mobileNumber ?? "")
        addressDict["postcode"] = registerVM?.postCode ?? ""
        addressDict["city"] = registerVM?.city ?? ""
        addressDict["firstname"] = registerVM?.firstName ?? ""
        addressDict["lastname"] = registerVM?.lastName ?? ""
        addressDict["Prefix"] = "Mr."
        addressDict["default_shipping"] = true
        addressDict["default_billing"] = true
        
        addressArray.add(addressDict)
        customerDict["addresses"] = addressArray
        
        paramDict["customer"] = customerDict as AnyObject
        paramDict["password"] = registerVM?.password as AnyObject
        return paramDict as AnyObject
    }
}
