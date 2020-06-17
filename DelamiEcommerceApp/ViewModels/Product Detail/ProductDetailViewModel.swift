//
//  ProductDetailViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 10/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

enum NavigateFrom {
    case catelogPage
    case detailPage
}

class ProductDetailViewModel: NSObject {
    var productModel: ProductModel?
    var productArray: [ProductDetailModel] = []
    var groupedProducts: [String: [ProductDetailModel]] = [:]
    
    var productConfiguration: ProductConfiguration = .none
    
    var colorOptions: [OptionValue]?
    var sizeOptions: [OptionValue]?
    //    var productAttributeOption: [AttributeOption]?
    var allColorOptions: [AttributeOption]?
    var allSizeOptions: [AttributeOption]?
    
    var dataSequenceModel: [ProductDataModel]?
    
    var cartCount: CartModel?
    var parentProductType: ProductType = .configurable
    var from: NavigateFrom? = .catelogPage
}

class CartModel: Decodable {
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case count = "qty"
    }
}

extension ProductDetailViewModel {
    func parseImage(imageUrl: String) -> ProductDataModel {
        let model = ProductDataModel()
        model.type = .image
        model.imageURL = imageUrl
        
        //        guard let imgPath = AppConfigurationModel.sharedInstance.productMediaUrl, let url = URL(string: imgPath + imageUrl ) else {
        //            return model
        //        }
        //
        //        let request = URLRequest(url: url)
        //        DispatchQueue.global(qos: .background).async {
        //            UIImageView().setImageWithUrlRequest(request, placeHolderImage: UIImage(), success: { (_, _, image, _) -> Void in
        //                DispatchQueue.main.async(execute: {
        //                    model.image = image
        //                })
        //            }, failure: nil)
        //        }
        return model
    }
    
    func parseDescription(data: String) -> ProductDataModel {
        let model = ProductDataModel()
        model.type = .description
        model.descriptionInfo = data
        return model
    }
    
    func parseURL(data: ProductStaticUrl) -> ProductDataModel {
        let model = ProductDataModel()
        model.type = .URLs
        model.urlLinks = data
        return model
    }
    
    func parseColor() -> ProductDataModel {
        let model = ProductDataModel()
        model.type = .color
        return model
    }
    
    func addBlankSpace() -> ProductDataModel {
        let model = ProductDataModel()
        model.type = .blank
        return model
    }
    
    func addDescriptionColorRow(productModel: ProductModel, urlData: ProductStaticUrl, productDataModal: inout [ProductDataModel]) {
        if let description = productModel.customAttributes?.filter({$0.attributeCode == "short_description"}).first?.value {
            productDataModal.append(parseDescription(data: description))
        }
        
        if parentProductType == .configurable {
            productDataModal.append(parseColor())
        }
    }
    
    func setProductData(model: ProductModel, urlData: ProductStaticUrl) -> [ProductDataModel] {
        var proDataModel: [ProductDataModel] = []
        
        if model.images?.count == 1 {
            proDataModel.append(parseImage(imageUrl: (model.images?.first?.file)!))
            addDescriptionColorRow(productModel: model, urlData: urlData, productDataModal: &proDataModel)
            proDataModel.append(parseURL(data: urlData))
            
        } else if model.images?.count == 2 {
            for index in 0..<2 {
                proDataModel.append(parseImage(imageUrl: (model.images?[index].file)!))
            }
            addDescriptionColorRow(productModel: model, urlData: urlData, productDataModal: &proDataModel)
            proDataModel.append(parseURL(data: urlData))
            
        } else if (model.images?.count)! > 2 {
            for index in 0..<2 {
                proDataModel.append(parseImage(imageUrl: (model.images?[index].file)!))
            }
            addDescriptionColorRow(productModel: model, urlData: urlData, productDataModal: &proDataModel)
            for index in 2 ..< (model.images?.count)! {
                proDataModel.append(parseImage(imageUrl: (model.images?[index].file)!))
            }
            proDataModel.append(parseURL(data: urlData))
            
        } else {
            proDataModel.append(addBlankSpace())
            addDescriptionColorRow(productModel: model, urlData: urlData, productDataModal: &proDataModel)
            proDataModel.append(parseURL(data: urlData))
        }
        return proDataModel
    }
    
    //    func parseProductAvailability(productModel: ProductModel) -> ProductAvailableModel? {
    //        // size parsing
    //        let availabilityModel = ProductAvailableModel()
    //        if let sizeAttribute = productModel.customAttributes?.filter({$0.attributeCode == "size"}).first {
    //            if let filteredSizeOption = self.sizeOptions?.filter({ "\($0.code!)" == sizeAttribute.value }).first {
    //                availabilityModel.size = filteredSizeOption.name
    //                availabilityModel.sizeCode = "\(filteredSizeOption.code ?? 0)"
    //                availabilityModel.isExist = filteredSizeOption.isActive ?? true
    //                availabilityModel.position = (self.sizeOptions?.index(where: { "\($0.code ?? 0)" == sizeAttribute.value })) ?? -1
    //            } else {
    //                return nil
    //            }
    //        }
    //
    //        availabilityModel.regularPrice = productModel.price != nil ? "\(productModel.price!)" : ""
    //        if let specialPrice = productModel.customAttributes?.filter({$0.attributeCode == "special_price"}).first?.value {
    //            availabilityModel.specialPrice = "\(specialPrice)"
    //        }
    //        availabilityModel.isInStock = productModel.extensionAttributes?.stockOptions?.isInStock ?? false
    //        availabilityModel.quantity = productModel.extensionAttributes?.stockOptions?.qty ?? 0
    //        return availabilityModel
    //    }
    
    func requestForChildrenOfProduct(skuId: String, success: @escaping((_ response: AnyObject?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        weak var weakSelf = self
        ConnectionManager().getChildrenOfProduct(skuId: skuId, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let productModelArray = try JSONDecoder().decode([ProductModel].self, from: jsonData)
                    
                    weakSelf?.requestForStaticPageUrl(success: { (data) in
                        if let parentproductModel = weakSelf?.productModel, let urlData = data {
                            weakSelf?.dataSequenceModel = weakSelf?.setProductData(model: parentproductModel, urlData: urlData)
                        }
                        
                        for productModel in productModelArray {
                            let detailModel = ProductDetailModel()
                            if let attribute = productModel.customAttributes?.filter({$0.attributeCode == "color"}).first, weakSelf?.productConfiguration == .colorSize || weakSelf?.productConfiguration == .color {
                                let colorAttribute = ColorAttribute()
                                let filteredColor = weakSelf?.allColorOptions?.filter({$0.value == attribute.value}).first
                                colorAttribute.color = filteredColor?.label
                                colorAttribute.colorCode = filteredColor?.value
                                colorAttribute.isExist = filteredColor?.label != nil ? true : false
                                colorAttribute.colorURL = productModel.images?.first?.file
                                detailModel.colorAttribute = colorAttribute
                            }
                            
                            if let attribute = productModel.customAttributes?.filter({$0.attributeCode == "size"}).first, weakSelf?.productConfiguration == .colorSize || weakSelf?.productConfiguration == .size {
                                let sizeAttribute = SizeAttribute()
                                let filteredSize = weakSelf?.allSizeOptions?.filter({$0.value == attribute.value}).first
                                sizeAttribute.size = filteredSize?.label
                                sizeAttribute.sizeCode = filteredSize?.value
                                sizeAttribute.isExist = filteredSize?.label != nil ? true : false
                                if let sizeOptions = weakSelf?.sizeOptions {
                                    sizeAttribute.position = (sizeOptions.index(where: { "\($0.code ?? 0)" == attribute.value })) ?? -1
                                }
                                detailModel.sizeAttribute = sizeAttribute
                            }
                            detailModel.regularPrice = productModel.price != nil ? "\(productModel.price!)" : ""
                            //                            if let specialPrice = productModel.customAttributes?.filter({$0.attributeCode == "special_price"}).first?.value {
                            if let specialPrice = productModel.extensionAttributes?.specialPrice {
                                detailModel.specialPrice = "\(specialPrice)"
                            }
                            detailModel.isInStock = productModel.extensionAttributes?.stockOptions?.isInStock ?? false
                            detailModel.quantity = productModel.extensionAttributes?.stockOptions?.qty ?? 0
                            weakSelf?.productArray.append(detailModel)
                            
                            if detailModel.colorAttribute != nil && detailModel.sizeAttribute != nil {
                                if let colorCode = detailModel.colorAttribute?.colorCode {
                                    if weakSelf?.groupedProducts[colorCode] == nil {
                                        weakSelf?.groupedProducts[colorCode] = [detailModel]
                                    } else {
                                        weakSelf?.groupedProducts[colorCode]?.append(detailModel)
                                    }
                                }
                            }
                            
                            //                            if let attribute = productModel.customAttributes?.filter({$0.attributeCode == "color"}).first {
                            //                                guard let model = weakSelf?.productArray.filter({ $0.colorCode == attribute.value }).first else {
                            //                                    let detailModel = ProductDetailModel()
                            //                                    let filteredColorOption = weakSelf?.colorOptions?.filter({ "\($0.code!)" == attribute.value }).first
                            //                                    detailModel.color = filteredColorOption?.name
                            //                                    detailModel.colorCode = "\(filteredColorOption?.code ?? 0)"
                            //                                    detailModel.isExist = filteredColorOption?.isActive ?? true
                            //                                    //                                    detailModel.data = weakSelf?.setProductData(model: productModel, urlData: data!)
                            //                                    detailModel.colorURL = productModel.images?.first?.file
                            //
                            //                                    // size parsing
                            //                                    if let availability = weakSelf?.parseProductAvailability(productModel: productModel) {
                            //                                        detailModel.availability.append(availability)
                            //                                    }
                            //
                            //                                    weakSelf?.productArray.append(detailModel)
                            //                                    continue
                            //                                }
                            //
                            //                                if let availability = weakSelf?.parseProductAvailability(productModel: productModel) {
                            //                                    model.availability.append(availability)
                            //                                    model.availability = model.availability.sorted(by: { $0.position < $1.position })
                            //                                }
                            //                            }
                        }
                        success(weakSelf?.productArray as AnyObject)
                        
                    }, failure: { (error) in
                        debugPrint(error?.localizedDescription ?? "Configuration API error")
                        failure(error!)
                        
                    })
                    
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success (msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure (nil)
            }
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
            failure(error!)
        })
    }
    
    func getProductDetails(skuId: String, success: @escaping((_ response: AnyObject) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().getProductDetail(skuId: skuId, success: { (response) in
            if let jsonData = response as? Data {
                do {
                    var viewModal = ProductModel()
                    viewModal = try JSONDecoder().decode(ProductModel.self, from: jsonData)
                    success(viewModal as AnyObject)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success (msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure (nil)
            }
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
            failure(error)
        })
    }
    
    // Product Datail Static Pages URL
    func requestForStaticPageUrl(success: @escaping((_ response: ProductStaticUrl?) -> Void), failure: @escaping((_ error: NSError?) -> Void)) {
        ConnectionManager().getStaticPageUrl(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    success(try JSONDecoder().decode(ProductStaticUrl.self, from: jsonData))
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
            failure(error!)
        })
    }
    
    // Product Color and Size Option
    func requestForProductAttributeOption(option: Option) {
        guard let attrId = option.attributeId, (option.name == "Color" || option.name == "Size" || option.name?.uppercased() == "Warna".uppercased() || option.name?.uppercased() == "Ukuran".uppercased()) && option.values.count > 0 else {
            return
        }
        
        ConnectionManager().getProductAttributeOption(attributeId: attrId, success: { [weak self] (response) in
            if let jsonData = response as? Data {
                do {
                    let options = try JSONDecoder().decode([AttributeOption].self, from: jsonData)
                    if option.name == "Color" || option.name?.uppercased() == "Warna".uppercased() {
                        self?.colorOptions = self?.filterAvailableOptions(allOptions: options, option: option)
                        self?.allColorOptions = options
                    } else {
                        let sizeOptionArray = self?.filterAvailableOptions(allOptions: options, option: option)
                        self?.sizeOptions = sizeOptionArray?.filter({ $0.isActive ?? true })
                        self?.allSizeOptions = options
                    }
                    //                    self?.productAttributeOption = options
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            }
            }, failure: { (error) in
                debugPrint(error?.localizedDescription ?? "Configuration API error")
        })
    }
    
    // add products to wishlist
    func addProductToWishList(productSKU: String, colorOptionID: Int?, colorOptionsValue: Int?, sizeOptionID: Int?, sizeOptionValue: Int?, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().addProductToWishList(productSKU: productSKU, colorOptionID: colorOptionID, colorOptionsValue: colorOptionsValue, sizeOptionID: sizeOptionID, sizeOptionValue: sizeOptionValue, success: { (response) in
            success(response)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func requestForAddToCartGuest(colorOptionID: Int?, colorOptionsValue: String?, sizeOptionID: Int?, sizeOptionValue: Int?, product: ProductModel, quantity: Int, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        let param = self.prepareCartRequestParam(colorOptionID: colorOptionID, colorOptionsValue: colorOptionsValue, sizeOptionID: sizeOptionID, sizeOptionValue: sizeOptionValue, product: product, userType: UserType.guest.rawValue, quantity: quantity)
        
        ConnectionManager().createRequestForAddToCartGuest(parameters: param, success: { (response) in
            weak var weakSelf = self
            if let jsonData = response as? Data {
                do {
                    weakSelf?.cartCount = try JSONDecoder().decode(CartModel.self, from: jsonData)
                    success((weakSelf?.cartCount)!)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success (msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
            
            //Triggered the Add To Cart Event after get success API Responce....
            let cartItemsDic: [String: Any] = [
                API.FacebookEventDicKeys.productname.rawValue: product.name ?? "",
                API.FacebookEventDicKeys.productSku.rawValue: product.sku ?? "",
                API.FacebookEventDicKeys.quantity.rawValue: quantity]
            AppEvents.logEvent(.init(FacebookEvents.addToCart.rawValue), parameters: cartItemsDic)
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
            failure(error)
        })
    }
    
    func requestForAddToCartUser(colorOptionID: Int?, colorOptionsValue: String?, sizeOptionID: Int?, sizeOptionValue: Int?, product: ProductModel, quantity: Int, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        let param = self.prepareCartRequestParam(colorOptionID: colorOptionID, colorOptionsValue: colorOptionsValue, sizeOptionID: sizeOptionID, sizeOptionValue: sizeOptionValue, product: product, userType: UserType.registeredUser.rawValue, quantity: quantity)
        
        ConnectionManager().createRequestForAddToCartUser(parameters: param, success: { (response) in
            weak var weakSelf = self
            if let jsonData = response as? Data {
                do {
                    weakSelf?.cartCount = try JSONDecoder().decode(CartModel.self, from: jsonData)
                    success((weakSelf?.cartCount)!)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                    success(msg as AnyObject)
                }
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
            
            //Triggered the Add To Cart Event after get success API Responce....
            let cartItemsDic : [String:Any] = ["Product Name": product.name ?? "", "Product SKU": product.sku ?? "", "Quantity": quantity]
            AppEvents.logEvent(.init(FacebookEvents.addToCart.rawValue), parameters: cartItemsDic)
            
        }, failure: { (error) in
            debugPrint(error?.localizedDescription ?? "Configuration API error")
            failure(error)
        })
    }
    
    // cart count get for guest and registered user.
    func requestForCartCount(userType: UserType, success:@escaping ((_ response: AnyObject) -> Void), failure:@escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().getCartCount(userType: userType, success: { (response) in
            
            if let cartCount = response as? Int {
                
                if userType == .registeredUser {
                    UserDefaults.standard.setUserCartCount(value: cartCount)
                } else { // guset cart handling
                    UserDefaults.standard.setGuestCartCount(value: cartCount)
                }
                success(cartCount as AnyObject)
            } else {
                debugPrint("failure: jsonData is not available")
                failure(nil)
            }
        }, failure: failure)
    }
    
    func filterAvailableOptions(allOptions: [AttributeOption]?, option: Option) -> [OptionValue] {
        var productOptions: [OptionValue] = []
        
        if let allOptionsArray = allOptions {
            for optionVal in allOptionsArray {
                if option.values.filter({ String($0.code ?? 0) == optionVal.value }).first != nil {
                    let optionValue = OptionValue()
                    optionValue.name = optionVal.label
                    optionValue.code = Int(optionVal.value ?? "0")
                    productOptions.append(optionValue)
                }
            }
        }
        
        if productOptions.count < option.values.count {
            for value in option.values {
                if !productOptions.contains(where: { $0.code == value.code }) {
                    let optionValue = OptionValue()
                    optionValue.name = ""
                    optionValue.code = value.code
                    optionValue.isActive = false
                    productOptions.append(optionValue)
                }
            }
        }
        
        //        for value in option.values {
        //            let availableOption = allOptions?.filter({$0.value == String(value.code ?? 0)}).first
        //            value.name = availableOption?.label
        //            productOptions.append(value)
        //        }
        return productOptions
    }
}

extension ProductDetailViewModel {
    fileprivate func prepareCartRequestParam(colorOptionID: Int?, colorOptionsValue: String?, sizeOptionID: Int?, sizeOptionValue: Int?, product: ProductModel, userType: String, quantity: Int) -> AnyObject? {
        if product.type?.rawValue == ProductType.simple.rawValue {
            var paramDict: [String: AnyObject?] = [:]
            var cartItemDict: [String: AnyObject?] = [:]
            
            cartItemDict["sku"] = product.sku?.encode() as AnyObject
            cartItemDict["qty"] = quantity as AnyObject
            var token: String? = ""
            if userType == UserType.guest.rawValue {
                token = UserDefaults.standard.getGuestCartToken()
            } else if userType == UserType.registeredUser.rawValue {
                token = UserDefaults.standard.getUserCartToken()
            }
            cartItemDict["quote_id"] = token as AnyObject
            paramDict["cartItem"] =  cartItemDict as AnyObject
            return paramDict as AnyObject
            
        } else {
            var paramDict: [String: AnyObject?] = [:]
            var cartItemDict: [String: AnyObject?] = [:]
            let configurableItemArray = NSMutableArray()
            var colorOptionDict: [String: AnyObject?] = [:]
            var sizeOptionDict: [String: AnyObject?] = [:]
            var extentionAttributeDict: [String: AnyObject?] = [:]
            var productOptionDict: [String: AnyObject?] = [:]
            
            cartItemDict["sku"] = product.sku as AnyObject
            cartItemDict["qty"] = quantity as AnyObject
            
            var token: String? = ""
            if userType == UserType.guest.rawValue {
                token = UserDefaults.standard.getGuestCartToken()
            } else if userType == UserType.registeredUser.rawValue {
                token = UserDefaults.standard.getUserCartToken()
            }
            cartItemDict["quote_id"] = token as AnyObject
            
            if let colorAttributeID = colorOptionID, let colorOptValue = colorOptionsValue {
                colorOptionDict["option_id"] = "\(colorAttributeID)" as AnyObject
                colorOptionDict["option_value"] = colorOptValue as AnyObject
                configurableItemArray.insert(colorOptionDict, at: 0)
            }
            
            if let sizeAttributeID = sizeOptionID, let sizeOptValue = sizeOptionValue {
                sizeOptionDict["option_id"] = "\(sizeAttributeID)" as AnyObject
                sizeOptionDict["option_value"] = "\(sizeOptValue)" as AnyObject
                
                //Write this condition to stop the crash on Add To Bag.......
                if configurableItemArray.count == 0 {
                    configurableItemArray.insert(sizeOptionDict, at: 0)
                } else {
                    configurableItemArray.insert(sizeOptionDict, at: 1)
                }
            }
            
            extentionAttributeDict["Configurable_item_options"] = configurableItemArray
            productOptionDict["extension_attributes"] = extentionAttributeDict as AnyObject
            cartItemDict["product_option"] = productOptionDict as AnyObject
            
            paramDict["cartItem"] =  cartItemDict as AnyObject
            return paramDict as AnyObject
        }
    }
}
