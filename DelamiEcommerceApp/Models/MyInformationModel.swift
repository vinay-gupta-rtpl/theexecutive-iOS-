//
//  MyInformationModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

struct MyInformationModel: Codable {
    // MARK: - MY Information API Parameters
    var identifier: Int64 = 0
    var defaultBilling: String? = ""
    var defaultshipping: String? = ""
    var email: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var addresses: [InfoAddress]?
    
    // MARK: - These Below parameters are not in used but decode just for send request parameter as it is in other request
    var groupID: Int64 = 0
    var createdAt: String = ""
    var updatedAt: String = ""
    var createdIn: String?
    var dob: String? = ""
    var prefix: String?
    var gender: Int? = 1
    var storeId: Int = 1
    var websiteId: Int = 1
    var disableAutoGroupChange: Int = 0
    
    enum CodingKeys: String, CodingKey {
        // getStore API Parameters
        case identifier = "id"
        case defaultBilling = "default_billing"
        case defaultshipping = "default_shipping"
        case email
        case firstname
        case lastname
        case addresses
        
        case groupID = "group_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdIn = "created_in"
        case dob
        case prefix
        case gender
        case storeId = "store_id"
        case websiteId = "website_id"
        case disableAutoGroupChange = "disable_auto_group_change"
    }
}

struct InfoAddress: Codable {
    // MARK: - addresses Parameters
    var addressId: Int64? = SystemConstant.defaultAddressId
    var region: Region?
    var countryId: String = ""
    var street: [String]?
    var telephone: String = ""
    var postcode: String? = ""
    var city: String?
    var firstname: String = ""
    var lastname: String = ""
    var defaultShipping: Bool? = false
    var defaultBilling: Bool? = false
    
    // MARK: - These Below parameters are not in used but decode just for send request parameter as it is in other request
    var customerId: Int64 = 0
    var regionId: Int64 = 0
    var prefix: String? = "Mr."
    
    enum CodingKeys: String, CodingKey {
        case addressId = "id"
        case region
        case countryId = "country_id"
        case street
        case telephone
        case postcode
        case city
        case firstname
        case lastname
        case defaultShipping = "default_shipping"
        case defaultBilling = "default_billing"
        case customerId = "customer_id"
        case regionId = "region_id"
        case prefix
    }
}

struct Region: Codable {
    // MARK: - region Parameters
    var regionCode: String = ""
    var regionName: String = ""
    var regionId: Int64 = 0
    
    enum CodingKeys: String, CodingKey {
        case regionCode = "region_code"
        case regionName = "region"
        case regionId = "region_id"
    }
}

extension MyInformationModel {
    func getMyInfo(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getMyInfo(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    DataStorage.instance.userAddressModel = try JSONDecoder().decode(MyInformationModel.self, from: jsonData)
                    success(DataStorage.instance.userAddressModel as AnyObject)
                    
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func requestForAddAddress(addressVM: InfoAddress, addressId: Int64, success:@escaping ((_ response: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        // set data in model
        let param = setAddressDataInModel(model: addressVM, addressId: addressId)
        
        ConnectionManager().changeInAddress(param: param, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    if DataStorage.instance.userAddressModel == nil {
                        DataStorage.instance.userAddressModel = MyInformationModel()
                    }
                    
                    DataStorage.instance.userAddressModel = try JSONDecoder().decode(MyInformationModel.self, from: jsonData)
                    success(DataStorage.instance.userAddressModel as AnyObject)
                    
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    // edit mobile number in My Information Page
    mutating func editPhoneNumberInAddress(addressVM: MyInformationViewModel, success:@escaping ((_ response: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        ConnectionManager().changeInAddress(param: setPhoneNumberInModel(addAddressVM: addressVM), success: { (response) in
            if let jsonData = response as? Data {
                do {
                    if DataStorage.instance.userAddressModel == nil {
                        DataStorage.instance.userAddressModel = MyInformationModel()
                    }
                    
                    DataStorage.instance.userAddressModel = try JSONDecoder().decode(MyInformationModel.self, from: jsonData)
                    success(DataStorage.instance.userAddressModel as AnyObject)
                    
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    // create parameter fot this
    mutating func setPhoneNumberInModel(addAddressVM: MyInformationViewModel) -> MyInformationModel {
        var userAddressModel = MyInformationModel()
        if let myInformationModel = DataStorage.instance.userAddressModel {
             userAddressModel = myInformationModel
        }
        
        for (index, addressModel) in (userAddressModel.addresses?.enumerated())! where addressModel.defaultShipping == true {
            var model = addressModel
            userAddressModel.addresses?.remove(at: index)
            model.telephone = addAddressVM.phoneCode! + "-" + addAddressVM.phoneNumber!
            userAddressModel.addresses?.insert(model, at: index)
            break
        }
        return userAddressModel
    }
    
    func changeInAddress(address: inout InfoAddress, changeType: AddressChangeType, success:@escaping ((_ response: AnyObject?) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        var parameter = MyInformationModel()
        if changeType.rawValue == AddressChangeType.makeDefaultAddress.rawValue {
            parameter = setDefaultAddress(defaultAddress: &address)
            
        } else if changeType.rawValue == AddressChangeType.removeAddress.rawValue {
            parameter = removeSelectedAddress(removedAddress: &address)
        }
        
        // set data in model
        ConnectionManager().changeInAddress(param: parameter, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    if DataStorage.instance.userAddressModel == nil {
                        DataStorage.instance.userAddressModel = MyInformationModel()
                    }
                    
                    DataStorage.instance.userAddressModel = try JSONDecoder().decode(MyInformationModel.self, from: jsonData)
                    success(DataStorage.instance.userAddressModel as AnyObject)
                    
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    // make address default
    func setDefaultAddress(defaultAddress: inout InfoAddress) -> MyInformationModel {
        var changeAddressModel = DataStorage.instance.userAddressModel
        for (index, addressModel) in (changeAddressModel?.addresses?.enumerated())! {
            var address = addressModel
            changeAddressModel?.addresses?.remove(at: index)
            
            if address.addressId == defaultAddress.addressId {
                address.defaultBilling = true
                address.defaultShipping = true
            } else {
                address.defaultBilling = nil
                address.defaultShipping = nil
            }
            changeAddressModel?.addresses?.insert(address, at: index)
        }
        return changeAddressModel!
    }
    
    // remove selected address
    func removeSelectedAddress(removedAddress: inout InfoAddress) -> MyInformationModel {
        var changeAddressModel = DataStorage.instance.userAddressModel
        for (index, addressModel) in (changeAddressModel?.addresses?.enumerated())! where addressModel.addressId == removedAddress.addressId {
            changeAddressModel?.addresses?.remove(at: index)
            break
        }
        return changeAddressModel!
    }
    
    // add / edit address
    func setAddressDataInModel(model: InfoAddress, addressId: Int64?) -> MyInformationModel {
        var addressArray = MyInformationModel()
        if let address = DataStorage.instance.userAddressModel {
            addressArray = address
        }
        if let addId = addressId, addId != 0 { // In case of edit address replace address model as it is.
            for (index, addressModel) in (addressArray.addresses?.enumerated())! where addressModel.addressId == addId {
                addressArray.addresses?.remove(at: index)
                addressArray.addresses?.insert(model, at: index)
                break
            }
        } else { // In case of add address append address model in whole MyInformation Model.
            addressArray.addresses?.append(model)
        }
        return addressArray
    }
    
    // request For Bank Transfer
    func requestForBankTransfer(paramModel: BankTransferViewModel, fileName: String, success:@escaping ((_ response: String) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().bankTransfer(paramModel: paramModel, fileName: fileName, success: { (response) in
            if let succeed = response as? String {
                success(succeed)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    // request for notification Count
    func requestForUnreadNotification(success:@escaping ((_ response: Int) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getUnreadNotificationCount(success: { (response) in
            if let count = response as? Int {
                success(count)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
}
