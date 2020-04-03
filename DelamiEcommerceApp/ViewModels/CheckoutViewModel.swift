//
//  CheckoutViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 21/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CheckoutViewModel: NSObject {
    var checkoutModel = CheckoutModel()
    var addresses: [InfoAddress] = []
    var shouldReload: Dynamic<Bool> = Dynamic(false)
    var shouldCheckForPayNow: Dynamic<Bool> = Dynamic(false)
    var selectedSection: Int = 0
    
    var cartAddressID: Int64?
    var cartShippingMethod: String?
    
    func requestForGetMyInformation() {
        MyInformationViewModel().requestForMyInfo(success: { [weak self] (response) in
            if let data = response as? MyInformationModel {
                self?.addresses = data.addresses ?? []
                self?.shouldReload.value = true
            } else {
                debugPrint("Error getting user information")
            }
            }, failure: { _ in
        })
    }
        
    func fetchShoppingCartItems() {
        Loader.shared.showLoading()
        ConnectionManager().getShoppingbagItemList(userType: .registeredUser, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([ShoppingBagModel].self, from: jsonData)
                    self?.checkoutModel.items = result
                    self?.shouldReload.value = true
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
            }, failure: { (_) in
                Loader.shared.hideLoading()
        })
    }
    
    func getCartTotalsInfo() {
        Loader.shared.showLoading()
        ShoppingCartViewModel().getCartTotal(userType: .registeredUser, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let totals = response as? [CartItemTotal] {
                self?.checkoutModel.totals = totals
                self?.shouldReload.value = true
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
        })
    }
    
    func requestForShippingMethods(addressId: Int64) {
        ConnectionManager().fetchShippingMethods(addressId: String(addressId), success: { [weak self] (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([ShippingMethodModel].self, from: jsonData)
                    self?.checkoutModel.shippingMethods = result
                    self?.checkoutModel.shippingMethods.first?.selected = true
                    self?.shouldReload.value = true
                    self?.requestForPaymentMethods()
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
        })
    }
    
    func requestForPaymentMethods() {
        guard let address = checkoutModel.address, let method = checkoutModel.shippingMethods.filter({ $0.selected == true }).first else {
            return
        }
        Loader.shared.showLoading()
        ConnectionManager().fetchPaymentMethods(address: address, shippingMethod: method, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(PaymentMethodAndTotalModel.self, from: jsonData)
                    self?.checkoutModel.paymentMethods = result.methods
                    self?.checkoutModel.totals = result.checkoutTotals?.totals ?? []
                    self?.shouldReload.value = true
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (error) in
            Loader.shared.hideLoading()
            debugPrint(error?.localizedDescription ?? "error in fetching payment methods")
        })
    }
    
    func placeOrder(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        if let paymentMethod = checkoutModel.paymentMethods.filter({ $0.selected == true }).first {
            ConnectionManager().placeOrder(paymentMethod: paymentMethod, success: { (response) in
                UserDefaults.instance.setUserCartToken(value: nil)
                UserDefaults.instance.setUserCartCount(value: 0)
                if let orderID = response as? String {
                    success(orderID as AnyObject)
                } else {
                    failure(NSError(domain: "", code: 200, userInfo: ["message": "Could not find order Id"]))
                }
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    func addOrderCommentWithSpecificOrder(orderId: String, status: String, success: @escaping ((_ response: Bool?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().addOrderCommentWithSpecificOrder(orderId: orderId, status: status, success: { (response) in
                success(true)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func getOrderDetails(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getOrderInfo(orderId: orderId, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(OrderInfoModel.self, from: jsonData)
                    success(result as AnyObject)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    failure(nil)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func requestForCancelAnOrder(orderId: String) {
        ConnectionManager().cancelOrder(orderId: orderId, success: { (response) in
            if let isCancelled = response as? Bool, isCancelled {
                debugPrint("is order cancelled: \(isCancelled)")
            } else {
                debugPrint("Cancel Order API: incorrect response")
            }
        }, failure: { (_) in
            debugPrint("Cancel Order API error")
        })
    }
}
