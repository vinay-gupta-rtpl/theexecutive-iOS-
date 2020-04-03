//
//  MyOrderService.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/17/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

class MyOrderService: BaseService {
    
    func getOrderHistory(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.orderHistory
        request.method = .get
        request.tokenType = .customer

        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getOrderDetail(orderId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = String(format: API.Path.orderDetail, orderId)      
        request.method = .get
        request.tokenType = .customer

        callWebServiceAlamofire(request, success: success, failure: failure)
    }

    func returnOrder(parameters: [String: AnyObject], success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.orderReturn
        request.parameters = parameters
        request.tokenType = .customer
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
