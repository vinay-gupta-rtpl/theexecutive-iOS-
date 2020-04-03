//
//  WishlistItemListModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class WishlistItemListModel: Decodable {
    var itemCount: Int = 0
    var items: [WishlistItemModel] = []
    
    enum CodingKeys: String, CodingKey {
        case itemCount = "items_count"
        case items
    }
}

class WishlistItemModel: Decodable {
    var productWishlistId: Int64?
    var productId: Int64?
    var type: ProductType?
    var name: String?
    var sku: String?
    var imageURL: String?
    var regularPrice: Double?
    var specialPrice: Double?
    var options: [WishlistProductOption]?
    var stockInfo: StockInfo?
    
    enum CodingKeys: String, CodingKey {
        case productWishlistId = "id"
        case productId = "product_id"
        case type = "type_id"
        case name
        case sku
        case imageURL = "image"
        case regularPrice = "regular_price"
        case specialPrice = "final_price"
        case options
        case stockInfo = "stock_item"
    }
}

class WishlistProductOption: Decodable {
    var label: String?
    var value: String?
    var attributeId: Int?
    var optionValue: Int?
    
    enum CodingKeys: String, CodingKey {
        case label
        case value
        case attributeId = "option_id"
        case optionValue = "option_value"
    }
}

    struct StockInfoModel: Decodable {
        var isInStock: Bool?

    enum CodingKeys: String, CodingKey {
        case isInStock = "is_in_stock"
    }
}
