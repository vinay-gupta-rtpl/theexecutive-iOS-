//
//  CartAndWishlistService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Alamofire

class CartAndWishlistService: BaseService {
    
    // Shopping cart APIs
    func getShoppingbagItemList(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        
        if userType == .registeredUser {
            request.path = API.Path.getCartItemCustomer + "?from_mobile=1"
            request.tokenType = .customer
            
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.getCartItemGuest + guestCartToken + "/items"
                    request.tokenType = .admin
            }
        }

        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func removeShoppingBagItem(itemId: Int64, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .delete
        
        if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.removeBagItemGuest + guestCartToken + "/items/" + String(itemId)
                request.tokenType = .admin
            }
        } else if userType == .registeredUser {
            request.path = API.Path.removeBagItemCustomer + String(itemId)
            request.tokenType = .customer
        }
        
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // move item from cart to wishlist
    func moveItemFromCartToWishlist(itemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .put
        request.path = API.Path.moveItemFromCartToWishlist + String(itemId)
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getCartTotal(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        
        if userType == .registeredUser {
            request.path = API.Path.getCartTotalCustomer + "?from_mobile=1"
            request.tokenType = .customer
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.getCartTotalGuest + guestCartToken + "/totals"
                request.tokenType = .admin
            }
        }
        
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getAppliedPromoCode(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .get
        
        if userType == .registeredUser {
            request.path = API.Path.getPromoCodeCustomer
            request.tokenType = .customer
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.getCartTotalGuest + guestCartToken + "/coupons"
                request.tokenType = .admin
            }
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func applyPromoCode(promoCode: String, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .put
        
        if userType == .registeredUser {
            request.path = API.Path.applyPromoCodeCustomer + promoCode + "?from_mobile=1"
            request.tokenType = .customer
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.applyPromoCodeGuest + guestCartToken + "/coupons/" + promoCode + "?from_mobile=1"
                request.tokenType = .admin
            }
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func deletePromoCode(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .delete
        
        if userType == .registeredUser {
            request.path = API.Path.deletePromoCodeCustomer
            request.tokenType = .customer
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.deletePromoCodeGuest + guestCartToken + "/coupons/"
                request.tokenType = .admin
            }
        }
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func updateCartItemQuantity(param: AnyObject, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.method = .put
        
        var itemId: String = ""
        if let cartDict = param["cartItem"] as? [String: AnyObject], let itemIdentifier = cartDict["item_id"] as? String {
            itemId = itemIdentifier
        }
        
        if userType == .registeredUser {
            request.path = API.Path.updateQuantityCustomer + itemId
            request.tokenType = .customer
        } else if userType == .guest {
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                request.path = API.Path.updateQuantityGuest + guestCartToken + "/items/" + itemId
                request.tokenType = .admin
            }
        }
        
        request.parameters = param as? [String: AnyObject]
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    // Wishlist APIs
    func getWishlistItems(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.wishlistItems
        request.method = .get
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func removeWishlistItem(wishlistItemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.removeWishlistItem + String(wishlistItemId) + "/delete/"
        request.method = .delete
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func moveItemToCartFromWishlist(wishlistItemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.moveToCartWishlistAPI + String(wishlistItemId) + "/addtocart/"
        request.method = .post
        request.parameters = [
            "Id": String(wishlistItemId) as AnyObject,
            "qty": 1 as AnyObject
        ]
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
}
