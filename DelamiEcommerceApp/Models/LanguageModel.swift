//
//  StoreModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 08/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

/*
 // Codeable parsing format
 Dictionary in Dictionary     =   [String:StoreModal].self
 Array of Modal/Dictionary  =   [StoreModal].self
 Single dictionary =  StoreModal.self
 */

struct LanguageModel: Decodable {
    
    // MARK: - getStore API Parameters
    var storeID: Int?
    var code: String?
    var name: String?
    var websiteId: Int?
    var storeGroupId: Int?
    
    enum CodingKeys: String, CodingKey {
        // getStore API Parameters
        case storeID = "id"
        case code
        case name
        case websiteId = "website_id"
        case storeGroupId = "store_group_id"
    }
}
