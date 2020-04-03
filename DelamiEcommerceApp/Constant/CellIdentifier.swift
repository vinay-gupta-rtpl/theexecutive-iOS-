//
//  CellIdentifier.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 22/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

enum MyAccountCellType: Int {
    case myInformation = 0
    case myOrders
    case shippingAddress
    case notification
    case subscribeToNewsletter
    case selectLanguage
    case bankTransfer
    case changePassword
    case buyingGuide
    case contactUs
    case setting
}

struct CellIdentifier {
    
    struct ProductDetail {
        static let image: String = "ProductImage_cell"
        static let description: String = "ProductDiscription_cell"
        static let availableColors: String = "AvailableColors_cell"
        static let otherImage: String = "OtherImages_cell"
        static let button: String = "Buttons_cell"
        static let wearWith: String = "WearWith_cell"
        static let addBag: String = "AddBag_cell"
        static let colorCollection: String = "availableColors"
        static let wearCollection = "wearWith"
        static let sizeCollection = "availableSizes"
    }
    
    struct AddressBook {
        static let cell = "AddressBookCell"
    }
    
    struct Notification {
        static let cell = "NotificationCell"
    }
    
    struct CartAndWishlist {
        static let cell = "CartAndWishlistCell"
        static let checkoutCell = "ShoppingBagCheckoutCell"
    }
    
    struct Order {
        static let myOrder = "MyOrderCell"
        static let itemDetail = "itemDetailCell"
        static let detail = "OrderDetailCell"
    }
    
    struct CheckoutAndOther {
        static let checkoutProduct = "CheckoutProductCell"
        static let checkoutOption = "CheckoutOptionCell"
        static let singleLabelTotal = "SingleLabelTotalCell"
        static let doubleLabelTotal = "DoubleLabelTotalCell"
        static let address = "AddressCell"
        static let checkoutItem = "CheckoutItemCell"
        static let option = "OptionCell"
        static let returnMode = "returnModeCell"
        
        static let language = "languageCell"
        static let category = "categoryCell"
        static let promotion = "promotionCell"
        static let promotionImage = "promotionImageCell"
        static let catalogProduct = "catalogProductCell"
        static let filter = "FilterCell"
        static let sortOption = "sortOptionCell"
    }
}
