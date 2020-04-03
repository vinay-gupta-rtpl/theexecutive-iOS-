//
//  AppUpdater.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 20/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

enum UpdateValue {
    case soft
    case hard
    case none
}

class AppUpdater: NSObject {
    static let sharedInstance = AppUpdater()
    var updateValue: UpdateValue = .none
    
    override init() {
        super.init()
    }
    
    func checkForVersionUpdate() -> Bool {
        let newVersion = AppConfigurationModel.sharedInstance.version
        let info = Bundle.main.infoDictionary
        
        guard let currentVersion = info?["CFBundleShortVersionString"] as? String, let appStoreVersion = newVersion else {
            return false
        }
        
        guard let verNum = Float(currentVersion), let appstoreNum = Float(appStoreVersion) else {
            return false
        }
        
        if verNum == appstoreNum {
            debugPrint("== App has the latest version")
            UserDefaults.standard.set(false, forKey: "isSoftUpdateReminded")
            return false
        } else if verNum.isLess(than: appstoreNum) {
            if (floor(appstoreNum) - floor(verNum)) < 1.0 {
                debugPrint("== soft update")
                updateValue = .soft
                return true
            } else {
                debugPrint("== hard update")
                updateValue = .hard
                return true
            }
        }
        return false
    }
}

extension UIViewController {
    func showAppUpdateAlert() {
        guard let appStoreUrl = AppConfigurationModel.sharedInstance.appstoreURL, AppUpdater.sharedInstance.updateValue != .none else {
            return
        }
        
        let alertMessage = "A new version of the The Executive App is available. Please update to access the latest features."
        let alertTitle = "New Version"
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        if AppUpdater.sharedInstance.updateValue == .soft {
            // checking that the soft update alert is previously reminded or not
            if UserDefaults.standard.bool(forKey: "isSoftUpdateReminded") {
                return
            }
            
            UserDefaults.standard.set(true, forKey: "isSoftUpdateReminded")
            
            let notNowButton = UIAlertAction(title: "Not Now", style: .default) { _ in
                appDelegate.isVersionUpdateAvailable = false
                debugPrint("Don't update it now")
            }
            alertController.addAction(notNowButton)
        }
        
        let updateButton = UIAlertAction(title: "Update", style: .default) { _ in
            guard let url = URL(string: appStoreUrl) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            if AppUpdater.sharedInstance.updateValue == .hard {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        alertController.addAction(updateButton)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}
