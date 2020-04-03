//
//  Configuration.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 09/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

enum Environment: String {
    case development    = "Development"
    case qat            = "QAT"
    case uat            = "UAT"
    case production     = "Production"
    
    var baseURL: String {
        switch self {
        case .development: return "https://ranosys.theexecutive.co.id/" //(server for comment order API)
        case .qat: return "https://theexecutive.co.id/"
        case .uat:  return "http://magento.theexecutive.co.id/"
        case .production: return "https://theexecutive.co.id/" //  // live Server
        }
    }
    
    var token: String {
        switch self {
        case .development: return "8hqbil0mrsrsxqhwd6dgaby6e1lg8tun"
        case .qat: return "8hqbil0mrsrsxqhwd6dgaby6e1lg8tun"
        case .uat:  return "1y41tsvx0gq3qte2huvpp4vqd6jxwkhn"
        case .production: return "8hqbil0mrsrsxqhwd6dgaby6e1lg8tun" // live
        }
    }
}

struct Zendesk {
    //    static let accountKey = "jOgk2T0lJCRIQvtZRGHLSssGtmgR6B2n"    // Roshan Singh Bisht's Account Key
    static let accountKey = "4gHlsXEXVL3ZjRJ6jA5W66wwYYcJPdef"      // Client's Account Key
    
    // MARK: - Client credentials
    //    Login : https://account.zopim.com/account/login?redirect_to=%2Faccount%2F
    //    user: wahyudi.ecommerce@delamibrands.com
    //    pass : Csonline123!
}

class Configuration {
    lazy var environment: Environment = {
        return getEnvironment()
    }()
    
    fileprivate func getEnvironment() -> Environment {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.range(of: Environment.development.rawValue) != nil {
                return Environment.development
            } else if configuration.range(of: Environment.qat.rawValue) != nil {
                return Environment.qat
            } else if configuration.range(of: Environment.uat.rawValue) != nil {
                return Environment.uat
            } else {
                return Environment.production
            }
        }
        return Environment.production
    }
}
