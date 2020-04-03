//
//  CategoryService.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 13/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Alamofire

class CategoryService: BaseService {
    func getCategoryList(success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.categoryList
        request.method = .get
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getCategoryProductsForPromotion(viewModel: CatalogViewModel?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.parameters = [
            "id": viewModel?.categoryId as AnyObject,
            "product_list_limit": "10" as AnyObject,
            "p": viewModel?.pageNumber as AnyObject
        ]
        request.path = API.Path.categoryProducts
        request.method = .get
        request.encoding = URLEncoding() as ParameterEncoding
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getCategoryProducts(viewModel: CatalogViewModel?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void), type: Bool) {
        var request = AlamofireRequestModal()
        
        request.parameters = [
            "p": viewModel?.pageNumber as AnyObject,
            "product_list_limit": viewModel?.productCountPerPage as AnyObject,
            "product_list_order": viewModel?.selectedSort as AnyObject
        ]
        
        if let direction = viewModel?.sortDirection {
            let directionString = direction == .asc ? "asc" : "desc"
            request.parameters?.updateValue(directionString as AnyObject, forKey: "product_list_dir")
        }
        if !type || viewModel?.searchProduct.value != "" {
            request.path = API.Path.searchProducts
            request.parameters?.updateValue(viewModel?.searchProduct.value as AnyObject, forKey: "q")
        } else {
            request.path = API.Path.categoryProducts
            request.parameters?.updateValue(viewModel?.categoryId as AnyObject, forKey: "id")
        }

        request.method = .get

        if let viewData = viewModel, viewData.isFilterApplied {
            let filters = getFilterParameters(viewData)
            filters.forEach {request.parameters?.updateValue($1 as AnyObject, forKey: $0)}
        }
        
        request.encoding = URLEncoding() as ParameterEncoding
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getCategorySortingOptions(sortType: String?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        request.path = API.Path.sortingOptions
        request.method = .get
        request.parameters = [
            "type": sortType as AnyObject
        ]
        request.encoding = URLEncoding() as ParameterEncoding
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
    
    func getFilterOptions(categoryId: String?, searchOptions: String, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        var request = AlamofireRequestModal()
        
        request.method = .get
        if searchOptions.isEmpty {
            request.path = API.Path.filterOptions
            request.parameters = [
                "id": categoryId as AnyObject
            ]
        } else {
            request.path = API.Path.searchFilter
            request.parameters = [
                "q": searchOptions as AnyObject
            ]
        }
        request.encoding = URLEncoding() as ParameterEncoding
        callWebServiceAlamofire(request, success: success, failure: failure)
    }
}

extension CategoryService {
    func getFilterParameters(_ viewModel: CatalogViewModel) -> [String: String] {
        var filterDict: [String: String] = [:]
        if let filters = viewModel.filterData?.filters {
            for filter in filters {
                if let selectedOption = filter.options?.filter({$0.selected ?? false}).first {
                    filterDict[selectedOption.code!] = selectedOption.value
                }
            }
        }
        if let _ = viewModel.priceFilterOption, let selectedPrice = viewModel.selectedPriceRange {
            filterDict["price"] = selectedPrice
        }
        return filterDict
    }
}
