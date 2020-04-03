//
//  AppConfigurationViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 06/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class LanguageViewModel: NSObject {
    var rule = ValidationRule()
    var apiError = ApiError()
    
    var languages: Dynamic<[LanguageModel]?> = Dynamic(nil)
}

extension LanguageViewModel {
    func requestForAppSupportedLanguages() {
        Loader.shared.showLoading()
        weak var weakSelf = self
        ConnectionManager().getLanguges(success: { (response) in
             Loader.shared.hideLoading()
            if let jsonData = response as? Data {
                do {
                    var stores = try JSONDecoder().decode([LanguageModel].self, from: jsonData)
                    stores = stores.filter { $0.storeID != 0 }
                    DataStorage.instance.languages = stores
                    weakSelf?.languages.value = stores
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (error) in
             Loader.shared.hideLoading()
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            DelamiViewController().showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { [weak self] _ in
                // retry for language list in case of API failure ...
                self?.requestForAppSupportedLanguages()
            })
        })
    }
}
