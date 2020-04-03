//
//  NotificationListingModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

struct NotificationModel: Codable {
    // MARK: - Notification Listing API Parameters
    
    var notificationID: Int64 = 0
    var title: String?
    var description: String = ""
    var image: String?
    var isMessageReaded: Bool = false
    var type: String = "" //NotificationType = .none
    var typeId: String?
    var redirectTitle: String?
    var sentDate: String?
    
    enum CodingKeys: String, CodingKey {
        // getStore API Parameters
        /* Notification_id is field that is not needed yet . we send for read status API is "id" value for notification_id key.
         while we come from push notification we send payload notification_id for read status notification id. */
        case notificationID = "id"
        case title
        case description
        case image
        case isMessageReaded = "is_read"
        case type
        case typeId = "type_id"
        case redirectTitle = "redirection_title"
        case sentDate = "sent_date"
    }
}
extension NotificationModel {
    
    func getNotificationList(success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        
        NotificationServices().getNotificationList(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([NotificationModel].self, from: jsonData)
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
    
    func updateReadStatus(notificationId: String, success: @escaping ((_ response: Bool?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        NotificationServices().updateReadStatus(notificationId: notificationId, success: { (response) in
            if let isresponseUpdated = response as? Bool {
               success (isresponseUpdated)
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
            print("error: Update read status API error")
            failure(nil)
        })
    }
}
