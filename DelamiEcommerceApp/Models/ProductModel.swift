//
//  ProductModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 20/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

class ProductListModel: Decodable {
    var products: [ProductModel]?
    var totalCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case products = "items"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.totalCount = try? container.decode(Int.self, forKey: .totalCount)
        self.products = try? container.decode([ProductModel].self, forKey: .products)
    }
}

class ProductModel: Decodable {
    var productId: Int?
    var sku: String?
    var name: String?
    var type: ProductType?
    var price: String?
    var images: [ProductImage]?
    var discount: Int? = 0
    var tag: String? = ""
    var collectionTag: String? = ""
    var extensionAttributes: ExtensionAttribute?
    var customAttributes: [CustomAttribute]?
    var productLinks: [ProductLinks]?
    
    enum CodingKeys: String, CodingKey {
        case productId = "id"
        case sku = "sku"
        case name
        case type = "type_id"
        case price
        case images = "media_gallery_entries"
        case extensionAttributes = "extension_attributes"
        case customAttributes = "custom_attributes"
        case productLinks = "product_links"
    }
    
    init() {
       
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.productId = try? container.decode(Int.self, forKey: .productId)
        self.sku = try? container.decode(String.self, forKey: .sku)
        self.name = try? container.decode(String.self, forKey: .name)
//        self.type = try? container.decode(String.self, forKey: .type)
        self.type = (try? container.decode(String.self, forKey: .type)).map { ProductType(rawValue: $0) }!
        if let price = try? container.decode(Double.self, forKey: .price) {
            self.price = String(format: "%.0f", price)
        }

        self.images = try container.decodeIfPresent([ProductImage].self, forKey: .images)
        self.extensionAttributes = try container.decodeIfPresent(ExtensionAttribute.self, forKey: .extensionAttributes)
        self.customAttributes = try container.decodeIfPresent([CustomAttribute].self, forKey: .customAttributes)
        self.productLinks = try (container.decodeIfPresent([ProductLinks].self, forKey: .productLinks))?.filter({ $0.linkType == "related" })
    }
}

class ExtensionAttribute: Decodable {
    var regularPrice: String?
    var specialPrice: String?
    var productOptions: [Option]?
    var stockOptions: Stock?
    var tagValue: String?
    enum CodingKeys: String, CodingKey {
        case regularPrice = "regular_price"
        case specialPrice = "final_price"
        case productOptions = "configurable_product_options"
        case stockOptions = "stock_item"
        case tagValue = "tag_text"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.productOptions = try container.decodeIfPresent([Option].self, forKey: .productOptions)
        if let regular = try container.decodeIfPresent(Double.self, forKey: .regularPrice) {
            self.regularPrice = String(format: "%.0f", regular)
        }
        if let special = try container.decodeIfPresent(Double.self, forKey: .specialPrice) {
            self.specialPrice = String(format: "%.0f", special)
        }
        if let stockOptionDict = try container.decodeIfPresent(Stock.self, forKey: .stockOptions) {
            self.stockOptions = stockOptionDict
        }
        self.tagValue = try? container.decode(String.self, forKey: .tagValue)
}
}

class Stock: Decodable {
    var qty: Int?
    var isInStock: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isInStock = "is_in_stock"
        case qty
    }
}

class Option: Decodable {
    var attributeId: String?
    var name: String?
    var values: [OptionValue] = []
    
    enum CodingKeys: String, CodingKey {
        case attributeId = "attribute_id"
        case name = "label"
        case values
    }
}

class CustomAttribute: Decodable {
    var attributeCode: String?
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case attributeCode = "attribute_code"
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.attributeCode = try container.decodeIfPresent(String.self, forKey: .attributeCode)
        do {
            self.value = try container.decodeIfPresent(String.self, forKey: .value)
        } catch DecodingError.typeMismatch {
            self.value = nil
        }
    }
}

class ProductLinks: Decodable {
    var skuId: String?
    var linkType: String?
    var linkedProductSkuId: String?
    var linkedProductType: String?
    var extensionAttribute: ProductLinkExtension?
    
    enum CodingKeys: String, CodingKey {
        case skuId = "sku"
        case linkType = "link_type"
        case linkedProductSkuId = "linked_product_sku"
        case linkedProductType = "linked_product_type"
        case extensionAttribute = "extension_attributes"
    }
}

class ProductLinkExtension: Decodable {
    var linkedProductName: String?
    var linkedProductImage: String?
    var linkedProductRegularPrice: Double?
    var linkedProductFinalPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case linkedProductName = "linked_product_name"
        case linkedProductImage = "linked_product_image"
        case linkedProductRegularPrice = "linked_product_regularprice"
        case linkedProductFinalPrice = "linked_product_finalprice"
    }
}

class OptionValue: Decodable {
    var name: String? = ""
    var code: Int?
    var isActive: Bool? = true
    
    enum CodingKeys: String, CodingKey {
        case code = "value_index"
    }
}

// MARK: - Global color and Size Option for Products.
class AttributeOption: Decodable {
    var label: String?
    var value: String?
}

class ProductImage: Decodable {
    var label: String?
    var types: [String] = []
    var file: String?
    
    enum CodingKeys: String, CodingKey {
        case label
        case types
        case file
    }
}

class ProductStaticUrl: Decodable {
    
    // MARK: - Product Datail Static Pages URL API Parameters
    var compositionAndCare: String = ""
    var sizeGuideline: String = ""
    var shipping: String = ""
    var returns: String = ""
    var buyingGuideline: String = ""
    
    enum CodingKeys: String, CodingKey {
        // Product Datail Static Pages URL
        case compositionAndCare = "composition_and_care"
        case sizeGuideline = "size_guideline"
        case shipping
        case returns
        case buyingGuideline = "buying_guideline"
    }
}
