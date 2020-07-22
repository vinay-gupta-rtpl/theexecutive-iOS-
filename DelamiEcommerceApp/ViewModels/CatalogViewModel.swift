//
//  CatalogViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 20/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: self.lowerBound.encodedOffset, length: self.upperBound.encodedOffset - self.lowerBound.encodedOffset)
    }
}

class CatalogViewModel: NSObject {
    var products: Dynamic<[ProductModel]?> = Dynamic(nil)
    var totalProducts: Int = 0
    var sortOptions: [SortOption]?
    var filterData: FilterModel?
    var priceFilterOption: FilterOption?
    
    var currentCategory: String = ""
    var isAppending: Bool = false
    var categoryId: Int?
    let productCountPerPage = 10
    var pageNumber: Int = 1
    var selectedSort: String?
    var searchProduct: Dynamic<String> = Dynamic("")
    var sortDirection: Direction?
    
    var isFilterApplied: Bool = false
    var selectedPriceRange: String?
}

extension CatalogViewModel {
    func getProductInfoOf(_ product: ProductModel?, cellWidth: CGFloat) -> NSAttributedString {
        var productInfoText = ""
        var shouldShowSpecialPrice = true
        
        if let type = product?.type, let price = product?.price, type == ProductType.simple {
            product?.extensionAttributes?.regularPrice = price
            if let special = product?.customAttributes?.filter({$0.attributeCode == "special_price"}).first {
                product?.extensionAttributes?.specialPrice = special.value
            }
        }
        
        if let name = product?.name { productInfoText = name.uppercased() + SystemConstant.newLine }
        
        if let regular = product?.extensionAttributes?.regularPrice {
            productInfoText += SystemConstant.defaultCurrencyCode.localized() + " " + regular.changeStringToINR()
            if let special = product?.extensionAttributes?.specialPrice, regular != special {
                let textSize = CGFloat(((regular + special).count * 7) + 10)   // here, 7 is for per character size and 10 as extra space counted
                productInfoText += textSize > cellWidth ? SystemConstant.newLine + SystemConstant.defaultCurrencyCode.localized() + " " + special.changeStringToINR() : " " + SystemConstant.defaultCurrencyCode.localized() + " " + special.changeStringToINR()
            } else {
                shouldShowSpecialPrice = false
            }
        }

        let finalString = NSMutableAttributedString(string: productInfoText)

        if let name = product?.name, let nameRange = productInfoText.range(of: name.uppercased())?.nsRange {
            finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 13.0), range: nameRange)
        }

        if let regularPrice = product?.extensionAttributes?.regularPrice, let priceRange = productInfoText.range(of: SystemConstant.defaultCurrencyCode.localized() + " " + regularPrice.changeStringToINR())?.nsRange {
            if !shouldShowSpecialPrice {
                finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 13.0), range: priceRange)
            } else {
                finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 12.0), range: priceRange)
                finalString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: priceRange)
                finalString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: priceRange)
            }
        }

        if let specialPrice = product?.extensionAttributes?.specialPrice, let priceRange = productInfoText.range(of: SystemConstant.defaultCurrencyCode.localized() + " " + specialPrice.changeStringToINR())?.nsRange, shouldShowSpecialPrice {
            finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 13.0), range: priceRange)
            finalString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: priceRange)
        }
        return finalString
    }
    
    func checkAndLoadRemainingProducts(_ scrollView: UIScrollView?) {
        guard let productScroll = scrollView, !(products.value?.count == totalProducts || totalProducts < productCountPerPage || isAppending) else {
            return
        }
        
        let yOffset: Float = Float(productScroll.contentOffset.y + productScroll.bounds.size.height - productScroll.contentInset.bottom)
        let scrollContentHeight: Float = Float(productScroll.contentSize.height)
        let reloadDistance: Float = Float(((MainScreen.width - 45.0)/2 * (2.9 / 2)) + 78.0) * 3   // reload distance is the distance on which api get started for remaining products
        
        if yOffset > (scrollContentHeight - reloadDistance) {
            if isAppending == false {
                isAppending = true
                pageNumber += 1
                debugPrint("page number: \(pageNumber)")
                if isFilterApplied {
                    requestForProducts(from: .filter)
                } else {
                    requestForProducts(from: .products)
                }
            }
        }
    }
    
    func calculateDiscount(_ product: ProductModel?) -> String? {
        if let type = product?.type, let price = product?.price, type == ProductType.simple {
            product?.extensionAttributes?.regularPrice = price
            if let special = product?.customAttributes?.filter({$0.attributeCode == "special_price"}).first {
                product?.extensionAttributes?.specialPrice = special.value
            }
        }
        
        if let regularPrice = product?.extensionAttributes?.regularPrice, let specialPrice = product?.extensionAttributes?.specialPrice {
            if let regular = Double(regularPrice), let special = Double(specialPrice) {
                return String(format: "%.0f", ((regular - special) / regular) * 100)
            } else {
                return nil
            }
        }
        return nil
    }
}

extension CatalogViewModel {

    func callType(screen: RequestType) -> Bool {
        switch screen {
        case .search:
            return false
        case .filter:
            return true
        case .products:
            return true
        }
//        if screen == "search" {
//            return false
//        } else {
//            return true
//        }
    }
    
    func requestForProductsForPromotionCategory() {
        if !isAppending {
            Loader.shared.showLoading()
        }
        weak var weakSelf = self
        ConnectionManager().getCategoryProductsForPromotion(viewModel: self, success: { (response) in
            Loader.shared.hideLoading()
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(ProductListModel.self, from: jsonData)
                        if (weakSelf?.products.value) != nil {
                            weakSelf?.products.value = (weakSelf?.products.value)! + (result.products ?? [])
                        } else {
                            weakSelf?.products.value = result.products
                        }
                        weakSelf?.totalProducts = result.totalCount ?? 0
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
        })
    }
    
    func requestForProducts(from: RequestType) {
        if !isAppending {
            Loader.shared.showLoading()
        }
        weak var weakSelf = self
        ConnectionManager().getCategoryProducts(viewModel: self, success: { (response) in
            Loader.shared.hideLoading()
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(ProductListModel.self, from: jsonData)
                    if self.callType(screen: from) {
                        if weakSelf?.products.value != nil && result.products != nil {
                            weakSelf?.products.value = (weakSelf?.products.value)! + (result.products ?? [])
                        } else {
                            weakSelf?.products.value = result.products
                        }
                        weakSelf?.totalProducts = result.totalCount ?? 0
                    } else {
                        // Search
                        weakSelf?.products.value = result.products
                        weakSelf?.totalProducts = result.totalCount ?? 0
                    }
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
            
            if from == .search {
                 //Triggered the Event For Searched Products with Keywprds....
                let searched: [String: Any] = [API.FacebookEventDicKeys.keyword.rawValue: self.searchProduct.value]
//                AppEvents.logEvent(.init(FacebookEvents.searched.rawValue), parameters: searched)
                AppEvents.logEvent(.searched, parameters: searched)
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
        }, type: callType(screen: from) )
    }

    func requestForSortByOptions() {
        weak var weakSelf = self
        ConnectionManager().getCategorySortingOptions(sortType: searchProduct.value.isEmpty ? "catalog" : "search", success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([SortOption].self, from: jsonData)
                    weakSelf?.sortOptions = result
                    weakSelf?.addDirectionSortOptions()
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            
        })
    }
    
    func requestForFilters() {
        weak var weakSelf = self
        
        ConnectionManager().getFilterOptions(categoryId: String(categoryId ?? 0), searchOptions: searchProduct.value, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(FilterModel.self, from: jsonData)
                    let priceFilter = result.filters?.filter({ $0.code == "price" }).first
                    weakSelf?.priceFilterOption = priceFilter
                    weakSelf?.filterData = result
                    weakSelf?.filterData?.filters = result.filters?.filter({ $0.code != "price" })
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            
        })
    }
}

extension CatalogViewModel {
    func addDirectionSortOptions() {
        let optionCodes = ["price"]
        for code in optionCodes {
            if let optionIndex = self.sortOptions?.index(where: {$0.attributeCode == code}) {
                let optionName = self.sortOptions?[optionIndex].attributeName ?? ""
                self.sortOptions?[optionIndex].attributeName = "\(optionName) (\(Direction.asc.rawValue))"
                
                let newOption = SortOption()
                newOption.attributeName = "\(optionName) (\(Direction.desc.rawValue))"
                newOption.attributeCode =  self.sortOptions?[optionIndex].attributeCode
                self.sortOptions?.insert(newOption, at: optionIndex + 1)
            } else {
                continue
            }
        }
    }
}
