//
//  DataStorage.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class DataStorage: NSObject {
    
    // singleton class creation
    static let instance = DataStorage()
    
    var languages: [LanguageModel]?
    
    var userAddressModel: MyInformationModel?
    
    var bankTransferMethod: [BankTransferModel]?
    var bankRecipient: [BankTransferModel]?
    
    var isLaunchedByNotificationCenter: Bool = false
}
