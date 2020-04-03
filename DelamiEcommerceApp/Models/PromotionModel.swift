//
//  PromotionModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 26/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

struct PromotionModel: Decodable {
    var entityId: String?
    var title: String?
    var description: String?
    let type: PromotionType?
    var value: String?
    var position: Int = 1
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case title
        case description
        case type
        case value
        case position
        case image
    }
}
