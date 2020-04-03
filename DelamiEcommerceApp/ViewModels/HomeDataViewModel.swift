//
//  HomeDataViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 13/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class HomeDataViewModel: NSObject {
    var promotions: Dynamic<[PromotionModel]?> = Dynamic(nil)
    var categories: Dynamic<[CategoryModel]?> = Dynamic(nil)
    var images: [String] = []
    
    var rule = ValidationRule()
    var apiError = ApiError()
    var searchProduct: Dynamic<String> = Dynamic("")

}

extension HomeDataViewModel {
    
    func requestForPromotionList() {
        ConnectionManager().getHomePromotions(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode([PromotionModel].self, from: jsonData)
                    self.promotions.value = result
                    debugPrint(result)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
        })
    }
    
    func requestForCategoryList() {
        weak var weakSelf = self
        ConnectionManager().getCategoryList(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(CategoryModel.self, from: jsonData)
                    let activeCategories = result.children.filter { $0.isActive }
                    let finalCategories = weakSelf?.addViewAllCategory(categories: activeCategories)
                    weakSelf?.downloadCategoryImages(categories: finalCategories)
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (error) in
            self.apiError.statusCode = error?.code
            self.apiError.message = error?.userInfo["error"] as? String ?? error?.localizedDescription
        })
    }
    
    func downloadCategoryImages(categories: [CategoryModel]?) {
        guard let categoryArray = categories else {
            return
        }
        
        for category in categoryArray {
            category.categoryImage = UIImage()
            
            // downloding and setting image
            if let mediaURL = AppConfigurationModel.sharedInstance.categoryMediaUrl {
                if let urlString = (mediaURL + category.imageUrl!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    let imageView = UIImageView()
                    DispatchQueue.global(qos: .background).async {
                        imageView.setImageWithUrlRequest(request, placeHolderImage: UIImage(), success: { (_, _, image, _) -> Void in
                            category.categoryImage = image
                            
                            DispatchQueue.main.async(execute: {
                                self.categories.value = categoryArray
                            })
                        }, failure: { (_, _, _) -> Void in
                        })
                    }
                }
            }
        }
    }
    
    func addViewAllCategory(categories: [CategoryModel]) -> [CategoryModel] {
        for category in categories {
            let viewAll = CategoryModel()
            viewAll.categoryId = category.categoryId
            viewAll.level = category.level
            viewAll.parentID = category.parentID
            viewAll.name = category.name
            viewAll.shouldShowViewAll = true
            category.children.insert(viewAll, at: 0)
        }
        return categories
    }
    
    func getMyAccountInfo() {
        ConnectionManager().getMyAccountInfo(success: { (response) in do {
            if let jsonData = response as? Data {
                if let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any?] {
                    appDelegate.userName = (jsonResult["firstname"] as? String ?? "") + " " + (jsonResult["lastname"] as? String ?? "")
                    appDelegate.userEmail = jsonResult["email"] as? String
                }
            }
        } catch let msg {
            debugPrint("JSON serialization error:" + "\(msg)")
            }
        }, failure: { _ in
            
        })
    }
}
