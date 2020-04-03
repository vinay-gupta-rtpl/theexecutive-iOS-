//
//  CheckoutModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 21/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CheckoutModel: NSObject {
    var items: [ShoppingBagModel] = []
    var address: InfoAddress?
    var shippingMethods: [ShippingMethodModel] = []
    var paymentMethods: [PaymentMethodModel] = []
    var totals: [CartItemTotal] = []
}

class ShippingMethodModel: Decodable {
    var carrierCode: String?
    var methodCode: String?
    var carrierTitle: String?
    var methodTitle: String?
    var amount: Double = 0.0
    var isAvailable: Bool = false
    var selected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case carrierCode = "carrier_code"
        case methodCode = "method_code"
        case carrierTitle = "carrier_title"
        case methodTitle = "method_title"
        case amount
        case isAvailable = "available"
    }
}

class PaymentMethodAndTotalModel: Decodable {
    var methods: [PaymentMethodModel] = []
    var checkoutTotals: CartTotalsModel?
    
    enum CodingKeys: String, CodingKey {
        case methods = "payment_methods"
        case checkoutTotals = "totals"
    }
}

class PaymentMethodModel: Decodable {
    var code: String?
    var title: String?
    var selected: Bool? = false
}

struct OrderInfoModel: Decodable {
    var orderId: String?
    var paymentMethod: String?
    var virtualAccountNumber: String?
    var orderStatusCode: String?
    var orderStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paymentMethod = "payment_method"
        case virtualAccountNumber = "virtual_account_number"
        case orderStatusCode = "status_code"
        case orderStatus = "order_state"
    }
}
