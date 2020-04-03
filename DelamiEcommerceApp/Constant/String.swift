//
//  String.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
let kMaintenanceActive = "1"
let kConfirmOrderButtonColor = #colorLiteral(red: 0.1774248779, green: 0.4233593643, blue: 0.4916039109, alpha: 1)

struct StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static let shop = UIStoryboard(name: "Shop", bundle: Bundle.main)
    static let myAccount = UIStoryboard(name: "MyAccount", bundle: Bundle.main)
    static let myCart = UIStoryboard(name: "MyCart", bundle: Bundle.main)
    static let order = UIStoryboard(name: "Order", bundle: Bundle.main)
    static let myAccountInfo = UIStoryboard(name: "MyAccountInfo", bundle: Bundle.main)
    static let checkout = UIStoryboard(name: "Checkout", bundle: Bundle.main)
}

struct SBIdentifier {
    static let rootViewController              = "RootViewController"
    static let language                        = "LanguageViewController"
    static let rootLogin                       = "loginNav"
    static let forgotPassword                  = "forgotPasswordVC"
    static let registerProfile                 = "registerProfileVC"
    static let myAccount                       = "myAccountVC"
    static let newsLetter                      = "newsLetterVC"
    static let catalog                         = "CatalogViewController"
    static let sortBy                          = "SortByViewController"
    static let filterBy                        = "FilterViewController"
    static let productDetail                   = "productDetailVC"
    static let productDetailPageViewController = "pageViewControllerVC"
    static let productDetailContainer          = "productDetailContainerVC"
    static let login                           = "loginVC"
    static let myInformation                   = "myInformationVC"
    static let addAddress                      = "addAddressVC"
    static let addressBook                     = "addressBookVC"
    static let notification                    = "notificationVC"
    static let changePassword                  = "changePasswordVC"
    static let shoppingBag                     = "shoppingBagVC"
    static let myOrder                         = "myOrderVC"
    static let orderDetail                     = "orderDetailVC"
    static let returnOrder                     = "returnOrderVC" 
    static let webPageController               = "DelamiWebViewController"
    static let bankTransfer                    = "bankTransferVC"
    static let checkout                        = "checkoutVC"
    static let orderStatus                     = "orderStatusVC"
    static let setting                         = "settingVC"
}

struct NavigationTitle {
    static let selectLanguage = "SELECT LANGUAGE"
    static let forgotPassword = "FORGOT PASSWORD"
    static let registration = "CREATE AN ACCOUNT"
    static let myInformation = "MY INFORMATION"
    static let addressBook = "ADDRESS BOOK"
    static let addAddress = "ADD ADDRESS"
    static let appName = "The Executive"
    static let editAddress = "EDIT ADDRESS"
    static let wishlist = "WISHLIST"
    static let checkout = "CHECKOUT"
    static let notificationListing = "NOTIFICATIONS"
    static let shoppingBag = "SHOPPING BAG"
    static let customerAndCare = "Care Instruction"
    static let sizeGuideline = "Size Guideline"
    static let shipping = "Shipping"
    static let returns = "Returns"
    static let buyingGuidelines = "Buying Guideline"
    static let bankTransferConfirmation = "BANK TRANSFER CONFIRMATION"
    static let promotion = "PROMOTION"
    static let termsAndCondition = "TERMS AND CONDITION"
    static let myAddress = "MY ACCOUNT"
    static let sortBy = "SORT BY"
    static let filter = "FILTER"
    static let buyingGuide = "Buying Guide"
    static let contactUs = "Contact Us"
}

struct OrderStatusMessage {
    static let orderPleaced = "Order Placed Successfully"
    static let ThanksForOrder = "Thanks for your order."
    static let orderCancelled = "Order Cancelled."
    static let orderCancelledConfirmed = "Your order has been cancelled."
    static let orderFailed = "Order Failed"
    static let orderFailedConfirmed = "Your order has been failed."
    static let receiveOrderConfirmation = "You will receive an order confirmation email with detail of your order."
    static let virtualAccountNumber = "Your Virtual Account Number is"
    static let bankAccountBCA = "Bank Account"
}

struct OrderButtonTitle {
    static let viewOrder = "View Order"
    static let continueShopping = "Continue Shopping"
}

struct CustomerKey {
    static let customerId = "customer_id"
    static let customerToken = "customer_token"
    static let username = "username"
    static let password = "password"
}

struct NavTitles {
    static let login = "Login"
    static let forgotPassword = "Forgot Password?"
    static let register = "Create an Account"
    static let newsLetter = "NEWSLETTER"
    static let changePassword = "CHANGE PASSWORD"
    static let myOrder = "MY ORDERS"
    static let setting = "Settings"
    static let returns = "Returns"
}

//struct  UserDefault {
//    static let storeId = "selectedStoreId"
//    static let storeWebsiteId = "selectedStoreWebsiteId"
//    static let userToken = "userToken"
//    static let guestCartToken = "guestCartToken"
//    static let userCartToken = "userCartToken"
//    static let guestCartCount = "guetsCartCount"
//    static let registeredUserCartCount = "registeredUserCartCount"
//    static let email = "email"
//    static let deviceToken = "deviceToken"
//    static let fcmRegisterationToken = "fcmToken"
//}

enum PickerTag: Int {
    case country = 1
    case state
    case city
    case mobileCode
    case transferMethod
    case bankRecipient
}

enum Gender: Int {
    case male = 1
    case female = 2
    case none
}

enum LoginType: String {
    case social = "social"
    case normal = ""
    case none
}

enum ProductType: String, Decodable {
    case configurable
    case simple
}

enum UserType: String {
    case guest
    case registeredUser
}

enum UpdateQuantityType: String {
    case increase
    case decrease
}

enum AddressChangeType: String {
    case makeDefaultAddress
    case removeAddress
}

enum OptionType: String {
    case color = "Color"
    case size = "Size"
}

enum BankTransfer: String {
    case recipients
    case transferMethod
}

enum ScreenType: String {
    case screenTypeCategory = "Category"
    case screenTypeProduct = "Product"
    case screenTypeCMS = "CMS"
}

enum Direction: String {
    case asc = "Low to High"
    case desc = "High to Low"
}

enum ComingFromScreen: String {
    case promotion
    case listing
    case myAccount
    case editAddress
    case addAddress
    case notificationListing
    case wishlist
    case appDelegate
    case shoppingBag
    case orderSuccess
}

enum PromotionType: String, Codable {
    case category = "Category"
    case product  = "Product"
    case CMS      = "CMS"
}

enum ProductConfigOption {
    case color
    case size
    case bothColorSize
    case none
}

enum ProductConfiguration {
    case color
    case size
    case colorSize
    case none
}

struct ConstantString {
    static let qty = "Qty"
    static let shippingAddress = "Shipping Address"
    static let shippingMethod = "Shipping Method"
    static let paymentMethod = "Payment Method"
    static let totals = "Totals"
    static let total = "Total"
    static let orderNo = "Order #"
    static let viewAll = "VIEW ALL"
    static let termsAndConditionFullString = "By creating an account, you agree to the applicable Terms & Conditions."
    static let termsAndCondition = "Terms & Conditions"
    static let privacyPolicy = "Privacy Policy"
    static let sku = "SKU"
    static let today = "Today"
    static let product = "Product"
    static let outOfStock = "Out of Stock"
    static let only = "Only"
    static let productAvailable = "product(s) available."
    static let itemsInCart = "Total 3 item(s) in your cart"
    static let itemsInWishlist = "Total 3 item(s) in your wishlist"
    static let sizeGuide = "Size Guide"
    static let selectSize = "Select Size"
    static let selectQuantity = "Select Quantity"
    static let returnMode = "Return Mode"
    static let courierReturn = "Return via courier (ex: JNE, RPX, SAP, etc.)"
    static let alphamartReturn = "Return via Alfamart (Free)"
}

struct ButtonTitles {
    static let done = "Done"
    static let edit = "EDIT"
    static let save = "SAVE"
    static let clear = "Clear"
    static let addToBag = "ADD TO BAG"
    static let addToWishlist = "Add to Wishlist"
}
