//
//  ProductService.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 11/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Alamofire

class ProductService: BaseService {
    func getChildrenOfProduct(skuId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.productChildern + skuId.encode() + "/children"
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getStaticPageUrl(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.productContentUrl
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getProductAttributeOption(attributeId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.productAttributeOption + attributeId + "/options"
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func addProductToWishList(productSKU: String, colorOptionID: Int?, colorOptionsValue: Int?, sizeOptionID: Int?, sizeOptionValue: Int?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var optionsDict: [String: String] = [:]
        if let colorAttrId = colorOptionID, let colorCode = colorOptionsValue {
            optionsDict["\(colorAttrId)"] = "\(colorCode)"
        }
        
        if let sizeAttrId = sizeOptionID, let sizeCode = sizeOptionValue {
            optionsDict["\(sizeAttrId)"] = "\(sizeCode)"
        }
        
        var request = AlamofireRequestModal()
        request.method = .post
        request.path = API.Path.addToWishList
        request.tokenType = .customer
        request.parameters = [
            "productSku": productSKU as AnyObject
//            "options": optionsDict as AnyObject
        ]
        
        callWebServiceAlamofire(request, success: success, failure: failure)
        
    }
    func getProduct(skuId: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.productDetail + skuId.encode()
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}
