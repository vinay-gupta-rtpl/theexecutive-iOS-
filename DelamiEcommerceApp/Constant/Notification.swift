//
//  Notification.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 04/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType: String, Codable {
    case category = "Category"
    case product  = "Product"
    case order    = "Order"
    case notificationListing = "NotificationListing"
    case abendentCart   = "Abandoned"
    case none      = ""
}

struct  UserDefault {
    static let storeId = "selectedStoreId"
    static let storeWebsiteId = "selectedStoreWebsiteId"
    static let selectedStoreIdentifier = "selectedStoreIdentifier"
    static let userToken = "userToken"
    static let guestCartToken = "guestCartToken"
    static let userCartToken = "userCartToken"
    static let guestCartCount = "guetsCartCount"
    static let registeredUserCartCount = "registeredUserCartCount"
    static let email = "email"
    static let deviceToken = "deviceToken"
    static let fcmRegisterationToken = "fcmToken"
    static let notificationIdArray = "notificationIdArray"
}
