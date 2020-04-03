//
//  ConnectionManager.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 23/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject {
    // MARK: - Configuration Service
    func getConfiguration(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConfigurationService().getConfiguration(success: success, failure: failure)
    }
    
    func getLanguges(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConfigurationService().getLanguges(success: success, failure: failure)
    }
    
    func getHomePromotions(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConfigurationService().getHomePromotions(success: success, failure: failure)
    }
    
    // MARK: - Category Service
    func getCategoryList(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CategoryService().getCategoryList(success: success, failure: failure)
    }
        
    func getCategoryProducts(viewModel: CatalogViewModel?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void), type: Bool) {
        CategoryService().getCategoryProducts(viewModel: viewModel, success: success, failure: failure, type: type)
    }

    func getCategoryProductsForPromotion(viewModel: CatalogViewModel?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
    CategoryService().getCategoryProductsForPromotion(viewModel: viewModel, success: success, failure: failure)
    }
    // MARK: - Product Detail Service
    func getChildrenOfProduct(skuId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProductService().getChildrenOfProduct(skuId: skuId, success: success, failure: failure)
    }
    
    func getStaticPageUrl(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProductService().getStaticPageUrl(success: success, failure: failure)
    }
    
    func getProductAttributeOption(attributeId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProductService().getProductAttributeOption(attributeId: attributeId, success: success, failure: failure)
    }
    
    func addProductToWishList(productSKU: String, colorOptionID: Int?, colorOptionsValue: Int?, sizeOptionID: Int?, sizeOptionValue: Int?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProductService().addProductToWishList(productSKU: productSKU, colorOptionID: colorOptionID, colorOptionsValue: colorOptionsValue, sizeOptionID: sizeOptionID, sizeOptionValue: sizeOptionValue, success: success, failure: failure)
    }
    
    func getProductDetail(skuId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProductService().getProduct(skuId: skuId, success: success, failure: failure)
    }
    
    // MARK: - Sorting Services
    func getCategorySortingOptions(sortType: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CategoryService().getCategorySortingOptions(sortType: sortType, success: success, failure: failure)
    }
    
    func getFilterOptions(categoryId: String?, searchOptions: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CategoryService().getFilterOptions(categoryId: categoryId, searchOptions: searchOptions, success: success, failure: failure)
    }
    
    // MARK: - Profile Service
    func doLogin(email: String, password: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().doLogin(email: email, password: password, success: success, failure: failure)
    }
    
    func doForgotPassword(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().doForgotPassword(email: email, success: success, failure: failure)
    }
    
    func logoutPerform(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().logoutPerform(success: success, failure: failure)
    }
    
    func doRegister(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().doRegister(parameters: parameters, success: success, failure: failure)
    }
    
    func isEmailAvailable(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().isEmailAvailable(email: email, success: success, failure: failure)
    }
    
    func requestForSocialLogin(email: String, token: String, loginType: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().requestForSocialLogin(email: email, token: token, loginType: loginType, success: success, failure: failure)
    }
    
    func getCountries(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().getCountries(success: success, failure: failure)
    }
    
    func getCities(regionId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().getCities(regionId: regionId, success: success, failure: failure)
    }
    
    func doSubscription(email: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().doSubscription(email: email, success: success, failure: failure)
    }
    
    func mergeGuestCartToUserCart(guestCartID: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().mergeGuestCartToUserCart(guestCartID: guestCartID, success: success, failure: failure)
    }
    
    func getMyAccountInfo(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().getMyAccountInfo(success: success, failure: failure)
    }
    
    // Create Guest Cart
    func createGuestCart(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().createGuestCart(success: success, failure: failure)
    }
    
    func createRequestedUserCart(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().createRequestedUserCart(success: success, failure: failure)
    }
    
    func createRequestForAddToCartGuest(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().requestForAddToCartGuest(parameters: parameters, success: success, failure: failure)
    }
    
    // Cart count update by one API
    func getCartCount(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().getCartCount(userType: userType, success: success, failure: failure)
    }
    
    func createRequestForAddToCartUser(parameters: AnyObject?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ProfileService().requestForAddToCartUser(parameters: parameters, success: success, failure: failure)
    }
    
    // CartAndWishlistService
    // MARK: - Shopping Bag Service
    func getShoppingbagItemList(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().getShoppingbagItemList(userType: userType, success: success, failure: failure)
    }
    
    func removeShoppingBagItem(itemId: Int64, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().removeShoppingBagItem(itemId: itemId, userType: userType, success: success, failure: failure)
    }
    
    func moveItemFromCartToWishlist(itemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().moveItemFromCartToWishlist(itemId: itemId, success: success, failure: failure)
    }
    
    func getCartTotal(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().getCartTotal(userType: userType, success: success, failure: failure)
    }
    
    func getAppliedPromoCode(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().getAppliedPromoCode(userType: userType, success: success, failure: failure)
    }
    
    func applyPromoCode(promoCode: String, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().applyPromoCode(promoCode: promoCode, userType: userType, success: success, failure: failure)
    }
    
    func deletePromoCode(userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().deletePromoCode(userType: userType, success: success, failure: failure)
    }
    
    func updateCartItemQuantity(param: AnyObject, userType: UserType, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().updateCartItemQuantity(param: param, userType: userType, success: success, failure: failure)
    }
    
    // MARK: - Wishlist services
    func getWishlistItems(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().getWishlistItems(success: success, failure: failure)
    }
    
    func removeWishlistItem(wishlistItemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().removeWishlistItem(wishlistItemId: wishlistItemId, success: success, failure: failure)
    }
    
    func moveItemToCartFromWishlist(wishlistItemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CartAndWishlistService().moveItemToCartFromWishlist(wishlistItemId: wishlistItemId, success: success, failure: failure)
    }
    
    // MARK: - Notification API
    func getNotificationList(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        NotificationServices().getNotificationList(success: success, failure: failure)
    }
    
    func updateReadStatus(notificationId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        NotificationServices().updateReadStatus(notificationId: notificationId, success: success, failure: failure)
    }
    
    func registerGuestDevice(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConfigurationService().registerGuestDevice(success: success, failure: failure)
    }
    
    // MARK: - Bank Transfer API
    func getTransferMethod(forType: BankTransfer, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        BankTransferService().getTransferMethod(forType: forType, success: success, failure: failure)
    }
    
    // MARK: - MyInformation Services
    func changePassword(currentPassword: String, newPassword: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyInformationService().changeInPassword(currentPassword: currentPassword, newPassword: newPassword, success: success, failure: failure)
    }
    func getMyInfo(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyInformationService().getConfiguration(success: success, failure: failure)
    }

    func changeInAddress(param: MyInformationModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyInformationService().changeInAddress(param: param, success: success, failure: failure)
    }
    
    // Bank Transfer Service
    func bankTransfer(paramModel: BankTransferViewModel, fileName: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyInformationService().bankTransfer(paramModel: paramModel, fileName: fileName, success: success, failure: failure)
    }

    // MARK: - Order Services
    func getOrderHistory(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyOrderService().getOrderHistory(success: success, failure: failure)
    }

    func getOrderDetail(orderID: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyOrderService().getOrderDetail(orderId: orderID, success: success, failure: failure)
    }

    func doOrderReturn(parameters: [String: AnyObject], success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyOrderService().returnOrder(parameters: parameters, success: success, failure: failure)
    }
    
    // Checkout Service
    func getCartAddressAndShipping(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().getCartAddressAndShipping(success: success, failure: failure)
    }
    
    func fetchShippingMethods(addressId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().fetchShippingMethods(addressId: addressId, success: success, failure: failure)
    }
    
    func fetchPaymentMethods(address: InfoAddress, shippingMethod: ShippingMethodModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().fetchPaymentMethods(address: address, shippingMethod: shippingMethod, success: success, failure: failure)
    }
    
    func placeOrder(paymentMethod: PaymentMethodModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().placeOrder(paymentMethod: paymentMethod, success: success, failure: failure)
    }
    
    func addOrderCommentWithSpecificOrder(orderId: String, status: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().addOrderCommentWithSpecificOrder(orderId: orderId, status: status, success: success, failure: failure)
    }
    
    func getOrderInfo(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().getOrderInfo(orderId: orderId, success: success, failure: failure)
    }
    
    func cancelOrder(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        CheckoutService().cancelOrder(orderId: orderId, success: success, failure: failure)
    }
    
    func getUnreadNotificationCount(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        MyInformationService().getUnreadNotificationCount(success: success, failure: failure)
    }
}
