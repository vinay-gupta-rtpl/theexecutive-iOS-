//
//  WearWithCollectionViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 16/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class WearWithCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func setupMethod(productLinkArray: [ProductLinks], indexPath: IndexPath) {
        if !productLinkArray.isEmpty {
            
            if let name = productLinkArray[indexPath.row].extensionAttribute?.linkedProductName {
                self.nameLabel.text = name.uppercased()
            }
            
            priceLabel.attributedText = self.getProductInfoOf(productLinkArray[indexPath.row], cellWidth: self.frame.size.width)
            priceLabel.textAlignment = .center
            imageView.contentMode = .scaleAspectFit
            
            if let imageUrl = productLinkArray[indexPath.row].extensionAttribute?.linkedProductImage {
                if let urlString = (AppConfigurationModel.sharedInstance.productMediaUrl! + imageUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    DispatchQueue.global(qos: .background).async {
                        self.imageView.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                            DispatchQueue.main.async(execute: {
                                self.imageView.alpha = 0.0
                                self.imageView.image = image
                                UIView.animate(withDuration: 0.5, animations: {self.imageView.alpha = 1.0})
                            })
                        }, failure: nil)
                    }
                }
            } else {
                self.imageView.image = Image.placeholder
            }
        }
    }

    func getProductInfoOf(_ product: ProductLinks?, cellWidth: CGFloat) -> NSAttributedString {
        var productInfoText = ""
        var shouldShowSpecialPrice = true
        
        if let type = product?.linkedProductType, let price = product?.extensionAttribute?.linkedProductRegularPrice, type == ProductType.simple.rawValue {
           product?.extensionAttribute?.linkedProductRegularPrice = price
        }
        
        if let regular = product?.extensionAttribute?.linkedProductRegularPrice {
            productInfoText += SystemConstant.defaultCurrencyCode.localized() + " " + String(regular).changeStringToINR()
            if let special = product?.extensionAttribute?.linkedProductFinalPrice, regular != special {
                let textSize = CGFloat((String(regular + special).count * 7) + 10)   // here, 7 is for per character size and 10 as extra space counted
                productInfoText += textSize > cellWidth ? SystemConstant.newLine + SystemConstant.defaultCurrencyCode.localized() + " " + String(special).changeStringToINR() : SystemConstant.defaultCurrencyCode.localized() + " " + String(special).changeStringToINR()
            } else {
                shouldShowSpecialPrice = false
            }
        }
        
        let finalString = NSMutableAttributedString(string: productInfoText)
    
        if let regularPrice = product?.extensionAttribute?.linkedProductRegularPrice, let priceRange = productInfoText.range(of: SystemConstant.defaultCurrencyCode.localized() + " " + String(regularPrice).changeStringToINR())?.nsRange {
            if !shouldShowSpecialPrice {
                finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 13.0), range: priceRange)
            } else {
                finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 12.0), range: priceRange)
                finalString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: priceRange)
                finalString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: priceRange)
            }
        }
        
        if let specialPrice = product?.extensionAttribute?.linkedProductFinalPrice, let priceRange = productInfoText.range(of: SystemConstant.defaultCurrencyCode.localized() + " " + String(specialPrice).changeStringToINR())?.nsRange, shouldShowSpecialPrice {
            finalString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 13.0), range: priceRange)
            finalString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: priceRange)
        }
        return finalString
    }
}
