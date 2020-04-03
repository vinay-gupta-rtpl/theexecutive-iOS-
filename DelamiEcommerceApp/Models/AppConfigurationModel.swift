//
//  AppConfigurationModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 06/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

/*
 // Codeable parsing format
 Dictionary in Dictionary     =   [String:StoreModal].self
 Array of Modal/Dictionary  =   [StoreModal].self
 Single dictionary =  StoreModal.self
 */

class AppConfigurationModel: Decodable {
    static var sharedInstance = AppConfigurationModel()
    
    private init() {}
    
    // MARK: - get configuration API Parameters
    var version: String?
    var maintenance: String?
    var maintenanceMessage: String?
    var appstoreURL: String?
    var productMediaUrl: String?
    var categoryMediaUrl: String?
    var voucherAmount: String?
    var subscriptionMessage: String?
    var homePromotionMessage: String?
    var homePromotionURL: String?
    var catalogListingPromotionMessage: String?
    var catalogListingPromotionURL: String?
    var buyingGuideUrl: String?
    var contactUsUrl: String?
    var termsAndConditionURL: String?
    
    enum CodingKeys: String, CodingKey {
        // getConfiguration API Parameters
        case version
        case maintenance
        case maintenanceMessage = "maintenance_message"
        case appstoreURL = "appstore_url"
        case productMediaUrl = "product_media_url"
        case categoryMediaUrl = "category_media_url"
        case voucherAmount = "voucher_amount"
        case subscriptionMessage = "subscription_message"
        case homePromotionMessage = "home_promotion_message"
        case homePromotionURL = "home_promotion_message_url"
        case catalogListingPromotionMessage = "catalog_listing_promotion_message"
        case catalogListingPromotionURL = "catalog_listing_promotion_message_url"
        case buyingGuideUrl = "buying_guide_url"
        case contactUsUrl = "contact_us_url"
        case termsAndConditionURL = "terms_and_condition_url"
    }
}

extension AppConfigurationModel {
    func requestForAppConfiguration() {
        ConnectionManager().getConfiguration(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(AppConfigurationModel.self, from: jsonData)
                    AppConfigurationModel.sharedInstance = result
                    appDelegate.isVersionUpdateAvailable = AppUpdater.sharedInstance.checkForVersionUpdate()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotifyMaintenanceOrVersionUpdate"), object: nil)
                    debugPrint(result)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
        })
    }
    
    // register guest devce for notification.
    func registerGuestDevice() {
        ConnectionManager().registerGuestDevice(success: { (_) in

        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Register guest device API error")
        })
    }
    
    //  // API call for read status of notification
    func updateReadStatusOfNotification(notificationId: String) {
        ConnectionManager().updateReadStatus(notificationId: notificationId, success: { (_) in
            
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "update read status API error")
        })
    }
}
