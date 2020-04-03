//
//  ShoppingBagModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 14/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

struct ShoppingBagModel: Decodable {
    var identifier: Int64?
    var skuId: String = ""
    var quantity: Int64 = 0
    var name: String = ""
    var specialPrice: Double?
    var productType: String = ""
    var quoteId: String?
    var productOption: CartItemExtensionAttribute?
    var productExtentionAttribute: ProductExtentionAttribute?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "item_id"
        case skuId = "sku"
        case quantity = "qty"
        case name
        case specialPrice = "price"
        case productType = "product_type"
        case quoteId = "quote_id"
        case productOption = "product_option"
        case productExtentionAttribute = "extension_attributes"
    }
}

struct CartItemExtensionAttribute: Decodable {
    var productExtentionAttribute: ProductOptionExtentionAttribute?
    
    enum CodingKeys: String, CodingKey {
        case productExtentionAttribute = "extension_attributes"
    }
}

struct ProductOptionExtentionAttribute: Decodable {
    var colorSizeConfigOption: [ConfigurationItem]?
    
    enum CodingKeys: String, CodingKey {
        case colorSizeConfigOption = "configurable_item_options"
    }
}

struct ConfigurationItem: Decodable {
    var extensionAttributes: ColorSizeExtention?
    
    enum CodingKeys: String, CodingKey {
        case extensionAttributes = "extension_attributes"
    }
}

struct ColorSizeExtention: Decodable {
    var colorSizeOptionLabel: String?
    var colorSizeOptionValue: String?
    
    enum CodingKeys: String, CodingKey {
        case colorSizeOptionLabel = "attribute_label"
        case colorSizeOptionValue = "option_label"
    }
}

struct ProductExtentionAttribute: Decodable {
    var regularPrice: Double?
    var productImage: String?
    var configurableSKU: String?
    var stockInfo: StockInfo?
    
    enum CodingKeys: String, CodingKey {
        case regularPrice = "regular_price"
        case productImage = "image"
        case configurableSKU = "configurable_sku"
        case stockInfo = "stock_item"
    }
}

struct StockInfo: Decodable {
    var itemId: Int64?
    var productId: Int64?
    var stockId: Int64?
    var quantity: Int64?
    var isInStock: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case productId = "product_id"
        case stockId = "stock_id"
        case quantity = "qty"
        case isInStock = "is_in_stock"
    }
}

struct CartTotalsModel: Decodable {
    var subtotalWithDiscount: Double = 0.0
    var totals: [CartItemTotal] = []
    
    enum CodingKeys: String, CodingKey {
        case subtotalWithDiscount = "subtotal_with_discount"
        case totals = "total_segments"
    }
}

struct CartItemTotal: Decodable {
    var code: String?
    var title: String?
    var value: Double = 0.0
}

// Cart related address and shipping method
class CartAddressAndShippingModel: Codable {
    var customerInfo: MyInformationModel?
    var address: InfoAddress?
    var method: String?
    
    enum CodingKeys: String, CodingKey {
        case customerInfo = "customer"
        case address
        case method
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.customerInfo = try? container.decode(MyInformationModel.self, forKey: .customerInfo)
        self.address = try container.decodeIfPresent(InfoAddress.self, forKey: .address)
        self.method = try container.decodeIfPresent(String.self, forKey: .method)
    }
}
