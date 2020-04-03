//
//  BankTransferViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 28/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class BankTransferViewModel: NSObject {
    
    // MARK: - view binding variables
    var firstName: String = ""
    var lastName: String = ""
    var emailID: String = ""
    var orderNumber: String = ""
    var bankNumber: String = ""
    var holderAccountNumber: String = ""
    
    var transferAmount: String = ""
    var bankRecipient: String = ""
    var transferMethod: String = ""
    var transferDate: String = ""
    var attachmentImage: Data?
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension BankTransferViewModel {
    // MARK: - Validation
    func performValidation() -> Bool {
        
        if firstName.isEmpty {
            rule.message = AlertValidation.Empty.firstName.localized()
            return false
        }
        if  lastName.isEmpty {
            rule.message = AlertValidation.Empty.lastName.localized()
            return false
        }
        if emailID.isEmpty {
            rule.message = AlertValidation.Empty.email.localized()
            return false
        }
        if !(emailID.isValidEmail()) {
            rule.message = AlertValidation.Invalid.email.localized()
            return false
        }
        if orderNumber.isEmpty {
            rule.message = AlertValidation.Empty.orderNumber.localized()
            return false
        }
        if bankNumber.isEmpty {
            rule.message = AlertValidation.Empty.bankNumber.localized()
            return false
        }
        if holderAccountNumber.isEmpty {
            rule.message = AlertValidation.Empty.holderAccountNumber.localized()
            return false
        }
        if transferAmount.isEmpty {
            rule.message = AlertValidation.Empty.transferAmount.localized()
            return false
        }
        if bankRecipient.isEmpty {
            rule.message = AlertValidation.Empty.bankRecipient.localized()
            return false
        }
        if transferMethod.isEmpty {
            rule.message = AlertValidation.Empty.transferMethod.localized()
            return false
        }
        if transferDate.isEmpty {
            rule.message = AlertValidation.Empty.transferDate.localized()
            return false
        } else {
            return true
        }
    }
    
    func requestForBankTransfer(success: @escaping((_ response: String) -> Void), failure: @escaping((_ error: NSError) -> Void)) {
//        let parameterDict = self.createDictForBankTransfer(bankTransferVM: self)
        let currentTimeStamp = Date().toMillis()
        let fileNAme = String(currentTimeStamp) + "_" + self.orderNumber
        MyInformationModel().requestForBankTransfer(paramModel: self, fileName: fileNAme, success: { response in
            success(response)
        }, failure: { error in
            failure(error!)
        })
    }
    
    func requestForMyInfo(success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        MyInformationModel().getMyInfo(success: { (response) in
            success(response)
            
        }, failure: { (error) in
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func createDictForBankTransfer(bankTransferVM: BankTransferViewModel) -> AnyObject {
        var bankTransferDict: [String: Any?] = [:]
        bankTransferDict["name"] = bankTransferVM.firstName + " " + bankTransferVM.lastName
        bankTransferDict["email"] = bankTransferVM.emailID
        bankTransferDict["orderNumber"] = bankTransferVM.orderNumber
        bankTransferDict["bankNumber"] = bankTransferVM.bankNumber
        bankTransferDict["HolderAccountNumber"] = bankTransferVM.holderAccountNumber
        bankTransferDict["transferAmount"] = bankTransferVM.transferAmount
        bankTransferDict["bankReciept"] = bankTransferVM.bankRecipient
        bankTransferDict["transferMethod"] = bankTransferVM.transferMethod
        bankTransferDict["transferDate"] = bankTransferVM.transferDate
//        bankRecipient["attachment"] = bankTransferVM.
        
        return bankTransferDict as AnyObject
    }
}

extension Date {
    func toMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
