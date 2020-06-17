//
//  ShoppingCartViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ShoppingCartViewModel: NSObject {
    var shoppingCartItems: Dynamic<[ShoppingBagModel]?> = Dynamic(nil)
    var totalProduct: Int64?
    var cartAddressAndShippingModel: CartAddressAndShippingModel?
    
    var cartTotals: CartTotalsModel?
    var promoCode: String?
    var wrongPromoApplied: Bool = false
    
    // MARK: - other variables
    var rule = ValidationRule()
    var apiError = ApiError()
}

extension ShoppingCartViewModel {
    func fetchShoppingBagItemList(userType: UserType, failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().getShoppingbagItemList(userType: userType, success: { [weak self] (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([ShoppingBagModel].self, from: jsonData)
                    // cart count API
                    DelamiTabBarViewModel().requestForGetCartCount(user: userType, success: { (_) in
                    }, failure: { (_) in
                    })
                    
                    // cart totals API
                    self?.getCartTotal(userType: userType, success: { (_) in
                        Loader.shared.hideLoading()
                        self?.shoppingCartItems.value = result
                    }, failure: { (_) in
                        Loader.shared.hideLoading()
                        self?.shoppingCartItems.value = result
                    })
                } catch let msg {
                    Loader.shared.hideLoading()
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                Loader.shared.hideLoading()
                debugPrint("failure: jsonData is not available")
            }
            }, failure: { (error) in
                Loader.shared.hideLoading()
                failure(error)
         })
    }
    
    // delete shopping bag Item
    func removeShoppingBagItem(itemId: Int64, userType: UserType) {
        ConnectionManager().removeShoppingBagItem(itemId: itemId, userType: userType, success: { [weak self] (_) in
            self?.fetchShoppingBagItemList(userType: userType, failure: { (_) in
            })
            }, failure: { (_) in
                Loader.shared.hideLoading()
                print("error: Shopping bag delete item API error")
        })
    }
    
    // move item from Cart to Wishlist
    func moveItemFromCartToWishlist(itemId: Int64, success: @escaping((_ response: String) -> Void), failure: @escaping(() -> Void)) {
        ConnectionManager().moveItemFromCartToWishlist(itemId: itemId, success: { [weak self] (response) in
            if let msg = response as? String {
                self?.fetchShoppingBagItemList(userType: .registeredUser, failure: { (_) in
                })
                success(msg as String)
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure()
        })
    }
    
    func getCartTotal(userType: UserType, success: @escaping((_ response: AnyObject) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().getCartTotal(userType: userType, success: { [weak self] (response) in
            if let jsonData = response as? Data {
                do {
                    self?.cartTotals = try JSONDecoder().decode(CartTotalsModel.self, from: jsonData)
                    print(self?.cartTotals?.subtotalWithDiscount ?? 0.0)
                    success(self?.cartTotals as AnyObject)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success(msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func getAppliedPromoCode(userType: UserType, success: @escaping((_ response: AnyObject) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().getAppliedPromoCode(userType: userType, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    if let result =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        success(result as AnyObject)
                    } else {
                        success("" as AnyObject)
                    }
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success(msg as AnyObject)
                }
            } else if let pomoCode = response as? String {
                success(pomoCode as AnyObject)
                
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func applyPromoCode(promoCode: String, userType: UserType, success: @escaping((_ response: Bool) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().applyPromoCode(promoCode: promoCode, userType: userType, success: { (response) in
            if let isPromoCodeApplied = response as? Bool {
                success(isPromoCodeApplied)
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func deleteAppliedPromoCode(userType: UserType, success: @escaping((_ response: Bool) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().deletePromoCode(userType: userType, success: { (response) in
           // self?.fetchShoppingBagItemList(userType: userType)
            if let isPromoCodeDeleted = response as? Bool {
                success(isPromoCodeDeleted)
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func updateCartItemQuantity(itemId: Int64, quoteId: String, quantity: Int, userType: UserType, success: @escaping((_ response: AnyObject? ) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        
        let parameter = makeRequestForUpdateQuantity(itemId: itemId, quoteId: quoteId, quantity: quantity)
        
        ConnectionManager().updateCartItemQuantity(param: parameter, userType: userType, success: { (response) in
            if let json = response as? Data {
                success(json as AnyObject)
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { [weak self] (error) in
            self?.apiError.statusCode = error?.code
            self?.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
            failure(error)
        })
    }
    
    func getCartAddressAndShipping() {
        ConnectionManager().getCartAddressAndShipping(success: { [weak self] (response) in
            do {
                if let jsonData = response as? Data {
                    if let customer = try? JSONDecoder().decode(CartAddressAndShippingModel.self, from: jsonData) {
                        self?.cartAddressAndShippingModel = customer
                        DataStorage.instance.userAddressModel = self?.cartAddressAndShippingModel?.customerInfo
                    }
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any?] {
                        if let shippingAssignments = ((jsonResult["extension_attributes"] as? [String: Any?])?["shipping_assignments"] as? [[String: Any?]])?.first {
                            if let shipping = shippingAssignments["shipping"] as? [String: Any?] {
                                if let addressId = (shipping["address"] as? [String: Any?])?["customer_address_id"] as? Int64, let method = shipping["method"] as? String {
                                    if let address = self?.cartAddressAndShippingModel?.customerInfo?.addresses?.filter({ $0.addressId == addressId }).first {
                                        self?.cartAddressAndShippingModel?.address = address
                                    }
                                    self?.cartAddressAndShippingModel?.method = method
                                }
                            }
                        }
                    }
                }
            } catch let msg {
                debugPrint("JSON serialization error:" + "\(msg)")
            }
            }, failure: { (_) in
        })
    }
    
    // make request for cart update quantity API.
    func makeRequestForUpdateQuantity(itemId: Int64, quoteId: String, quantity: Int) -> AnyObject {
        
        var paramDict: [String: AnyObject?] = [:]
        var cartItemDict: [String: String?] = [:]
        
        cartItemDict["item_id"] = String(itemId)
        cartItemDict["qty"] = String(quantity)
        cartItemDict["quote_id"] = quoteId
        
        paramDict["cartItem"] = cartItemDict as AnyObject
        return paramDict as AnyObject
    }
}

extension ShoppingCartViewModel {
    func validateCartId() {
        
    }
}
