//
//  MyOrderModel.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/11/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class MyOrderModel: Decodable {

    // MARK: - MY Information API Parameters
    var productId: String?
    var price: String?
    var status: String?
    var dateOfOrder: String = ""
    var imageURL: String? = ""
    var isRefundable: Bool? = false

    enum CodingKeys: String, CodingKey {
        case productId = "id"
        case price = "amount"
        case status
        case dateOfOrder = "date"
        case imageURL = "image"
        case isRefundable = "is_refundable"
    }
}

class OrderDetailModel: Decodable {
    // MARK: - MY Information API Parameters
    var firstName: String = ""
    var lastName: String = ""
    var date: String = ""
    var items: [OrderProductModel]?
    var grandTotal: Int?
    var subtotalInclTax: Int = 0
    var shippingInclTax: Int = 0
    var email: String?
    var extensionAttributes: OrderDetailExtensionAttribute?
    var totalOrderedQty: Int?

    enum CodingKeys: String, CodingKey {
        case date = "created_at"
        case items
        case grandTotal = "grand_total"
        case subtotalInclTax = "subtotal_incl_tax"
        case shippingInclTax = "shipping_incl_tax"
        case firstName = "customer_firstname"
        case lastName = "customer_lastname"
        case email = "customer_email"
        case extensionAttributes = "extension_attributes"
        case totalOrderedQty = "total_qty_ordered"
    }
}

class OrderProductModel: Decodable {
    var productId: Int?
    var itemId: Int?
    var sku: String?
    var name: String?
    var price: Int?
    var qty: Int?
    var extensionAttribute: ItemExtensionAttribute?
    var reason = ""
    var isSelected: Bool = false
    var qtyReturned: Int = 0

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case sku = "sku"
        case name
        case itemId = "item_id"
        case qty = "qty_ordered"
        case price
        case extensionAttribute = "extension_attributes"
    }
}

class ItemExtensionAttribute: Decodable {
    var imageURL: String?
    var options: [WishlistProductOption]?

    enum CodingKeys: String, CodingKey {
        case imageURL = "image"
        case options
    }

}

class OrderDetailExtensionAttribute: Decodable {
    var formattedShippingAddress: InfoAddress?
    var returnToAddress: OrderReturnAddress?
    var paymentMethod: String?
    var virtualAccountNumber: String? = ""

//    payment_method

    enum CodingKeys: String, CodingKey {
        case formattedShippingAddress = "formatted_shipping_address"
        case returnToAddress = "returnto_address"
        case paymentMethod = "payment_method"
        case virtualAccountNumber = "virtual_account_number"
    }
}

class OrderReturnAddress: Decodable {
    var returnToName: String?
    var returnToAddress: String?
    var returnToContact: String?

    enum CodingKeys: String, CodingKey {
        case returnToName = "returnto_name"
        case returnToAddress = "returnto_address"
        case returnToContact = "returnto_contact"
     }

}

extension MyOrderModel {

    func getOrderHistory(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getOrderHistory(success: { (response) in

            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([MyOrderModel].self, from: jsonData)
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
}

extension OrderDetailModel {
    func getOrderDetail(orderID: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getOrderDetail(orderID: orderID, success: { (response) in

            if let jsonData = response as? Data {
                do {

                    //API RESULT SET INTO MODEL
                    let result = try JSONDecoder().decode(OrderDetailModel.self, from: jsonData)
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

    func doReturn(orderDetailModel: OrderDetailModel, orderNo: String, selectedMode: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        let param = self.prepareParam(orderDetailModel: orderDetailModel, orderNo: orderNo, returnMode: selectedMode)
        ConnectionManager().doOrderReturn(parameters: param, success: { (response) in
            success(response)
        }, failure: failure)
    }

    func prepareParam(orderDetailModel: OrderDetailModel, orderNo: String, returnMode: String) -> [String: AnyObject] {
        var paramDict: [String: AnyObject] = [:]
        var orderDict: [String: Any?] = [:]
        var items: [[String: Any]] = []

        for obj in orderDetailModel.items! where obj.isSelected == true {
                var tempDict: [String: Any] = [:]
                tempDict["item_id"] = obj.itemId
                tempDict["reason"] = obj.reason
                tempDict["qty"] = obj.qtyReturned
                items.append(tempDict)
        }
        if items.count == 0 {
            print("NO ITEM FOUND")
        }
        orderDict["orderId"] =  "\(orderNo)"
        orderDict["return_mode"] = returnMode
        orderDict["items"] = items

        paramDict["rmaData"] = orderDict as AnyObject
        return paramDict
    }
}
