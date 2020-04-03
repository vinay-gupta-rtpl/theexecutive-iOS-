//
//  AddAddressViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class AddAddressViewModel: NSObject {
    
    var firstName: String?
    var lastName: String?
    var streetAddress1: String?
    var streetAddress2: String?
    var phoneCode: String = "+62"
    var phoneNumber: String?
    var country: String?
    var state: String?
    var city: String?
    var postCode: String?
    
    var selectedRegion: Region?
    var selectedCountryId: String = "ID"
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension AddAddressViewModel {
    
    // MARK: - Validation
    func performValidation() -> Bool {
        if firstName == nil || (firstName?.isEmpty)! {
            rule.message = AlertValidation.Empty.firstName.localized()
            return false
        }
        if  lastName == nil || (lastName?.isEmpty)! {
            rule.message = AlertValidation.Empty.lastName.localized()
            return false
        }
        if streetAddress1 == nil || (streetAddress1?.isEmpty)! {
            rule.message = AlertValidation.Empty.address.localized()
            return false
        }
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
        if postCode == nil || (postCode?.isEmpty)! {
            rule.message = AlertValidation.Empty.postcode.localized()
            return false
        }
        if !((postCode?.count ?? 0) == 5) {
            rule.message = AlertValidation.Invalid.postcode.localized()
            return false
        } else {
            return true
        }
    }
    
    // MARK: - API Call
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
    
    func requestForAddAddress(model: InfoAddress, addressId: Int64, success: @escaping((_ response: AnyObject) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        
        MyInformationModel().requestForAddAddress(addressVM: model, addressId: addressId, success: { (response) in
            success(response!)
        }, failure: { error in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
}
