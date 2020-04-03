//
//  LoginModal.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

struct LoginModel: Decodable {
    var customerToken: String?

    enum CodingKeys: String, CodingKey {
        case customerToken = "access_token"
    }
}

extension LoginModel {
    func doLogin(email: String, password: String, success:@escaping (() -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().doLogin(email: email, password: password, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(LoginModel.self, from: jsonData)
                    debugPrint(result)
                    UserDefaults.standard.set(self.customerToken, forKey: CustomerKey.customerToken)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
            success()
        }, failure: failure)
    }
}
