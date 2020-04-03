//
//  BankTransferModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 31/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

struct BankTransferModel: Codable {
    // MARK: - Bank Transfer API Parameters
    var label: String?
    var value: String?
}

extension BankTransferModel {
    func getTransferMethod(forType: BankTransfer, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        ConnectionManager().getTransferMethod(forType: forType, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([BankTransferModel].self, from: jsonData)
                    if forType == .recipients {
                         DataStorage.instance.bankRecipient = result
                    } else { // Transfer Methods
                        DataStorage.instance.bankTransferMethod = result
                    }
                    success (result as AnyObject)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success (msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
            print("error: Get notification listing API error")
            failure(nil)
        })
    }
}
