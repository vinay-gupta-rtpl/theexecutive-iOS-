//
//  CheckoutService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 21/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CheckoutService: BaseService {
    func getCartAddressAndShipping(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.registeredUserCart + "?fields=customer,extension_attributes[shipping_assignments[shipping]]"
        request.method = .get
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func fetchShippingMethods(addressId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.getShippingMethods
        request.method = .post
        request.parameters = [
            "addressId": addressId as AnyObject
        ]
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func fetchPaymentMethods(address: InfoAddress, shippingMethod: ShippingMethodModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.getPaymentMethods
        request.method = .post
        request.parameters = createPaymentMethodRequest(address: address, shippingMethod: shippingMethod)
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func placeOrder(paymentMethod: PaymentMethodModel, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.placeOrder
        request.parameters = [
            "paymentMethod": [
                "method": paymentMethod.code ?? ""
            ] as AnyObject
        ]
        request.method = .post
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }

    func addOrderCommentWithSpecificOrder(orderId: String, status: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.orderCommentWithSpecificOrderPre + orderId + API.Path.orderCommentWithSpecificOrderPost
        request.method = .post
        request.tokenType = .admin
        request.parameters = createCommentRequest(status: status)
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getOrderInfo(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.orderInfo + orderId + "/information"
        request.method = .get
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func cancelOrder(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.orderInfo + orderId + "/cancel"
        request.method = .put
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}

extension CheckoutService {
    func createPaymentMethodRequest(address: InfoAddress, shippingMethod: ShippingMethodModel) -> [String: AnyObject] {
        do {
            var parameters: [String: AnyObject] = [:]
            let jsonData = try JSONEncoder().encode(address)
            var jsonDict = try (JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]).flatMap({ $0 })
            
            if let region = jsonDict?["region"] as? [String: AnyObject], let addressId = jsonDict?["id"] {
                jsonDict?.updateValue(region["region"] as AnyObject, forKey: "region")
                jsonDict?.updateValue(region["region_id"] as AnyObject, forKey: "region_id")
                jsonDict?.updateValue(region["region_code"] as AnyObject, forKey: "region_code")
                jsonDict?.updateValue(addressId as AnyObject, forKey: "customer_address_id")
            }
            
            jsonDict?.removeValue(forKey: "id")
            jsonDict?.removeValue(forKey: "default_billing")
            jsonDict?.removeValue(forKey: "default_shipping")
            
            let addressInfo = [
                "shipping_address": jsonDict as AnyObject,
                "billing_address": jsonDict as AnyObject,
                "shipping_carrier_code": shippingMethod.carrierCode as AnyObject,
                "shipping_method_code": shippingMethod.methodCode as AnyObject
            ]
            parameters["addressInformation"] = addressInfo as AnyObject
            return parameters
        } catch {
            debugPrint("JSON serialization error:")
        }
        return [:]
    }
    
    func createCommentRequest(status: String) -> [String: AnyObject] {
       var dict = [String: AnyObject]()
        var commentDict = [String: AnyObject]()
        commentDict["comment"] = "[MobileOrder-iOS]" as AnyObject
        commentDict["status"] = status as AnyObject
        dict["statusHistory"] = commentDict as AnyObject
        return dict
    }
}
