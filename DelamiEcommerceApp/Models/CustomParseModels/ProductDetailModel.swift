//
//  ProductDetailModel.swift
//  DelamiEcommerceApp
//
//  Created by Kritika on 25/4/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

enum ProductDataType {
    case image
    case description
    case color
    case URLs
    case blank
}

// Modal for product detail table
class ProductDataModel: NSObject {
    var type: ProductDataType = ProductDataType.image
    var image: UIImage?
    var imageURL: String?
    var descriptionInfo: String?
    var urlLinks: ProductStaticUrl?
}

// Modal for product detail "Add to bag" view
class ProductAvailableModel: NSObject {
    var size: String?
    var sizeCode: String?
    var isExist: Bool = true
    var position: Int = -1
    var regularPrice: String?
    var specialPrice: String?
    var quantity: Int = 0
    var isInStock: Bool = false
}
/*
class ProductDetailModel: NSObject {
    var data: [ProductDataModel]?
    var availability: [ProductAvailableModel] = []
    var color: String?
    var colorCode: String?
    var isExist: Bool = true
    var colorImage: UIImage?
    var colorURL: String?
}
*/
class ProductDetailModel: NSObject {
    //    var data: [ProductDataModel]?
    //    var availability: [ProductAvailableModel] = []
    var colorAttribute: ColorAttribute?
    var sizeAttribute: SizeAttribute?
    var regularPrice: String?
    var specialPrice: String?
    var quantity: Int = 0
    var isInStock: Bool = false
    
    //    var color: String?
    //    var colorCode: String?
    //    var isExist: Bool = true
    //    var colorImage: UIImage?
    //    var colorURL: String?
}

class ColorAttribute: NSObject {
    var color: String?
    var colorCode: String?
    var isExist: Bool = true
    var colorImage: UIImage?
    var colorURL: String?
}

class SizeAttribute: NSObject {
    var size: String?
    var sizeCode: String?
    var position: Int = -1
    var isExist: Bool = true
}
