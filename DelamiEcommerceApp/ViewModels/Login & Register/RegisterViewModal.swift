//
//  RegisterViewModal.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 01/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class RegisterViewModal: NSObject {
    // MARK: - view binding variables
    var firstName: String?
    var lastName: String?
    var emailID: String?
    var gender: Int?
    var mobileCode: String = "+62"
    var mobileNumber: String?
    var country: String?
    var state: String?
    var city: String?
    var postCode: String?
    var birthDate: String?
    var password: String?
    var confirmPassword: String?
    var isSubscribed: Bool?
    
    var loginType: String = ""
    
    var streetAddressLine1: String?
    var streetAddressLine2: String?
    
    var selectedRegion: RegionModel?
    var selectedCountryId: String = ""
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension RegisterViewModal {
    // MARK: - API Call
    func requestForRegister(success: @escaping((_ response: String?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        UserModel().doRegister(registerVM: self, success: { (_) in
            if let guestCartCount = UserDefaults.standard.getGuestCartCount(), guestCartCount > 0  && self.loginType == "social" {
                if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                    LoginViewModel().mergeGuestCartToUser(guestCartId: guestCartToken, success: { (_) in
                        success(self.loginType)
                    }, failure: { (_) in
                        success(self.loginType)
                    })
                } else {
                    success(self.loginType)
                }
            } else {
                success(self.loginType)
            }
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func requestForCustomerLogin(success: @escaping((_ response: AnyObject) -> Void), failure: @escaping(() -> Void)) {
        UserModel().doLogin(email: emailID!, password: password!, success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure()
        })
    }
    
    func requestForSocialLogin(email: String, token: String, loginType: String, success: @escaping(() -> Void), failure: @escaping((_ error: NSError) -> Void)) {
        UserModel().requestForSocialLogin(email: email, token: token, loginType: loginType, success: {
            success()
        }, failure: { (error) in
            failure (error!)
        })
    }
    
    func requestForCountries(success: @escaping((_ response: AnyObject) -> Void), failure: @escaping(() -> Void)) {
        RegisterModel().getCountries (success: { (response) in
            success(response)
        }, failure: { (_) in
            
            failure()
        })
    }
    
    func requestForCities(regionId: String, success: @escaping((_ response: AnyObject) -> Void), failure: @escaping(() -> Void)) {
        RegisterModel().getCities (regionId: regionId, success: { (response) in
            success(response)
        }, failure: { (_) in
            
            failure()
        })
    }
    
    // MARK: - Validation
    func performValidation() -> Bool {
        // check first name & last name validation
        if firstName == nil || (firstName?.isEmpty)! {
            rule.message = AlertValidation.Empty.firstName.localized()
            return false
        }
        
        if (firstName?.count ?? 0) > 50 {
            rule.message = AlertValidation.Invalid.firstName.localized()
            return false
        }
        
        if  lastName == nil || (lastName?.isEmpty)! {
            rule.message = AlertValidation.Empty.lastName.localized()
            return false
        }
        
        if (lastName?.count ?? 0) > 50 {
            rule.message = AlertValidation.Invalid.lastName.localized()
        }
        
        // check email address validation
        if emailID == nil || (emailID?.isEmpty)! {
            rule.message = AlertValidation.Empty.email.localized()
            return false
        }
        if !(emailID?.isValidEmail())! {
            rule.message = AlertValidation.Invalid.email.localized()
            return false
        }
        
        // check mobile number validation
        if mobileNumber == nil || (mobileNumber?.isEmpty)! {
            rule.message = AlertValidation.Empty.mobileNumber.localized()
            return false
        }
        if !(mobileNumber?.isValidMobileNumber())! {
            rule.message = AlertValidation.Invalid.mobileNumber.localized()
            return false
        }
/*
        // check DOB validation
        if birthDate == nil || (birthDate?.isEmpty)! {
            rule.message = AlertValidation.Empty.birthDate.localized()
            return false
        }
*/
        // check street address 1 validation
        if streetAddressLine1 == nil || (streetAddressLine1?.isEmpty)! {
            rule.message = AlertValidation.Empty.address.localized()
            return false
        }
        
        // check country, state and city validation
        if country == nil || (country?.isEmpty)! {
            rule.message = AlertValidation.Empty.country.localized()
            return false
        }
        if state == nil || (state?.isEmpty)! {
            rule.message = AlertValidation.Empty.state.localized()
            return false
        }
        if city == nil || (city?.isEmpty)! {
            rule.message = AlertValidation.Empty.city.localized()
            return false
        }
        
        // check postal code validation
        if postCode == nil || (postCode?.isEmpty)! {
            rule.message = AlertValidation.Empty.postcode.localized()
            return false
        }
        
        if !((postCode?.count ?? 0) == 5) {
            rule.message = AlertValidation.Invalid.postcode.localized()
            return false
        }
        
        // check password validation
        if password == nil || (password?.isEmpty)! {
            rule.message = AlertValidation.Empty.password.localized()
            return false
        }
        
        if !(password?.isValidPassword())! {
            rule.message = AlertValidation.Invalid.password.localized()
            return false
        }
        
        // check confirm password validation
        if confirmPassword == nil || (confirmPassword?.isEmpty)! {
            rule.message = AlertValidation.Empty.confirmPassword.localized()
            return false
        }
        
        if !(password == confirmPassword) {
            rule.message = AlertValidation.Invalid.passwordAndConfirmPasswordDiffer.localized()
            return false
        } else {
            return true
        }
    }
}
