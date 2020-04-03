//
//  CategoryModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 13/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

class CategoryModel: Decodable {
    var categoryId: Int?
    var parentID: Int?
    var name: String?
    var isActive: Bool = true
    var level: Int = 0
    var productCount: Int?
    var imageUrl: String? = ""
    var categoryImage: UIImage? = UIImage()
    var children: [CategoryModel] = []
    var collapsed: Bool? = false // additional variable to manage expand/collapse of categories
    var shouldShowViewAll: Bool? = false // additional variable to to show view all sub category
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "id"
        case parentID = "parent_id"
        case name
        case isActive = "is_active"
        case level
        case productCount = "product_count"
        case imageUrl = "image"
        case children = "children_data"
        case collapsed
    }
}

class SortOption: Decodable {
    var attributeCode: String?
    var attributeName: String?
    var selected: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case attributeCode = "attribute_code"
        case attributeName = "attribute_name"
    }
}

class FilterModel: Decodable {
    var totalCount: Int?
    var filters: [FilterOption]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case filters
    }
}

class FilterOption: Decodable {
    var name: String?
    var code: String?
    var options: [FilterOptionValue]?
}

class FilterOptionValue: Decodable {
    var label: String?
    var code: String?
    var value: String?
    var selected: Bool? = false
}
