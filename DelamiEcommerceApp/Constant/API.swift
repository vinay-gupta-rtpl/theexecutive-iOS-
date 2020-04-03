//
//  API.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

enum ApiTokenType {
    case admin
    case customer
    case none
}

struct API {
    static let routes = "rest/"
    static let baseURL = Configuration().environment.baseURL + routes
    
    struct Headers {
        static let Authorization = "Authorization"
        static let ContentType = "Content-Type"
    }
    
    struct Path {
        static let adminToken                   = "/V1/integration/admin/token"
        static let configuration                = "/V1/mobileappversionapi/configuration/ios"
        static let store                        = "/V1/store/storeViews"
        static let homePromotions               = "/V1/homepromotions/list/"
        static let categoryList                 = "/V1/categoriescustom"
        static let categoryProducts             = "/V1/productslist"
        static let sortingOptions               = "/V1/attributes/sort"
        static let filterOptions                = "/V1/layerednavigation/filters"
        static let searchFilter                 = "/V1/layerednavigation/searchfilters"
        static let login                        = "/V1/integration/customer/token"
        static let forgotPassword               = "/V1/customers/password"
        static let register                     = "/V1/customers"
        static let isEmailAvailable             = "/V1/customers/isEmailAvailable"
        static let socialLogin                  = "/V1/customer/sociallogin/token"
        static let getCountries                 = "/V1/directory/countries"
        static let getCities                    = "/V1/custom/cities/"
        static let subscribe                    = "/V1/newsletter/subscribe"
        static let productContentUrl            = "/V1/productcontent/url"
        static let productAttributeOption       = "/V1/products/attributes/"
        static let productChildern              = "/V1/configurable-products/"
        static let guestCart                    = "/V1/guest-carts"
        static let registeredUserCart           = "/V1/carts/mine"
        static let searchProducts               = "/V1/catalogsearch/list/"
        static let addToWishList                = "/V1/wishlist/mine/addproduct/"
        static let addToCartForRegisteredUser   = "/V1/carts/mine/items"
        static let addToCartForGuest            = "/V1/guest-carts/"
        static let guestCartCount               = "/V1/guest-carts/"
        static let registeredUserCartCount      = "/V1/cart/mine/count"
        static let productDetail                = "/V1/products/"
        static let cartMergeAPI                 = "/V1/cart/mine/mergecart/"
        static let shoppingBagItemList          = "/V1/carts/mine/items"
        static let myInformation                = "/V1/customers/me"
        static let wishlistItems                = "/V1/wishlist/mine/info"
        static let removeWishlistItem           = "/V1/wishlist/mine/item/"
        static let moveToCartWishlistAPI        = "/V1/wishlist/mine/item/"
        static let registerGuestFornotification = "/V1/notification/registerdevice"
        static let notificationList             = "/V1/notification/mine/list"
        static let updateReadStatus             = "/V1/notification/changestatus"
        static let changePassword               = "/V1/customers/me/password"
        static let orderHistory                 = "/V1/orders/mine"
        static let orderDetail                  = "/V1/order/%@/mine"
        static let orderReturn                  = "/V1/rma/productreturn"
        // Bank Transfer Paths
        static let bankTransfer                 = "/V1/banktransfer/submit"
        static let getTransferMethods           = "/V1/banktransfer/transfermethods"
        static let getTransferRecipients        = "/V1/banktransfer/recipients"
        static let logout                       = "/V1/notification/mine/logout"
        static let unreadNotificationCount     = "/V1/notification/mine/count"
        
        // Shopping Bag
        static let removeBagItemGuest           = "/V1/guest-carts/"
        static let removeBagItemCustomer        = "/V1/carts/mine/items/"
        static let getCartItemGuest             = "/V1/guest-carts/"
        static let getCartItemCustomer          = "/V1/carts/mine/items"
        static let moveItemFromCartToWishlist   = "/V1/wishlist/mine/movefromcart/"
        static let getCartTotalCustomer         = "/V1/carts/mine/totals"
        static let getCartTotalGuest            = "/V1/guest-carts/"
        static let getPromoCodeCustomer         = "/V1/carts/mine/coupons"
        static let getPromoCodeGuest            = "/V1/guest-carts/"
        static let applyPromoCodeCustomer       = "/V1/carts/mine/coupons/"
        static let applyPromoCodeGuest          = "/V1/guest-carts/"
        static let deletePromoCodeCustomer      = "/V1/carts/mine/coupons"
        static let deletePromoCodeGuest         = "/V1/guest-carts/"
        static let updateQuantityCustomer       = "/V1/carts/mine/items/"
        static let updateQuantityGuest          = "/V1/guest-carts/"
        
        // Checkout APIs
        static let getShippingMethods           = "/V1/carts/mine/estimate-shipping-methods-by-address-id"
        static let getPaymentMethods            = "/V1/carts/mine/shipping-information"
        static let placeOrder                   = "/V1/carts/mine/payment-information"
        static let orderCommentWithSpecificOrderPre = "/V1/orders/"
        static let orderCommentWithSpecificOrderPost = "/comments"
        static let orderInfo                    = "/V1/order/mine/"
    }
    
    struct Token {
        static let adminToken = Configuration().environment.token
    }
}
