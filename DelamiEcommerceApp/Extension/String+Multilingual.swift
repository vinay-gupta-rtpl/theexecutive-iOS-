//
//  String+Multilingual.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/10/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        guard let storeCode = UserDefaults.instance.getStoreCode() else {
            return self
        }
        
        let localeCode = storeCode == "ID" ? "id-ID" : "en_us"
        if let path = Bundle.main.path(forResource: localeCode, ofType: "lproj") {
            let bundle = Bundle(path: path)
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        } else {
            return self
        }
    }
}
