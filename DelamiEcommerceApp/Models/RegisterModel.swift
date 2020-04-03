//
//  RegisterModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 23/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

struct RegisterModel: Decodable {
    // MARK: - Country API Parameters
    var identifier: String = ""
    var fullNameLocal: String = ""
    var fullNameEnglish: String = ""
    var availableRegions: [RegionModel]?
    
    enum CodingKeys: String, CodingKey {
        // getStore API Parameters
        case identifier = "id"
        case fullNameLocal = "full_name_locale"
        case fullNameEnglish = "full_name_english"
        case availableRegions = "available_regions"
    }
}

struct RegionModel: Decodable {
    // MARK: - Region Parameters
    var regionId: String = ""
    var code: String = ""
    var name: String = ""
    
    enum CodingKeys: String, CodingKey {
        case regionId = "id"
        case code
        case name
    }
}

struct CityModel: Decodable {
    // MARK: - City Parameters
    var name: String = ""
    var value: Int?
}

extension RegisterModel {
    func getCountries(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getCountries(success: { (response) in
            
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([RegisterModel].self, from: jsonData)
                    debugPrint(result)
                    success(result as AnyObject)
                    
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
    
    func getCities(regionId: String, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getCities(regionId: regionId, success: { (response) in
            
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([CityModel].self, from: jsonData)
                    debugPrint(result)
                    success(result as AnyObject)
                    
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
}
