//
//  CountryModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 04/09/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

struct CountryModal: Decodable {
    var name: String?
    // swiftlint:disable identifier_name
    var dial_code: String?
    var code: String?
    
    func loadJson(filename fileName: String) -> [CountryModal]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([CountryModal].self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}
