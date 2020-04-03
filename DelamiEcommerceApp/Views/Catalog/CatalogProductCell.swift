//
//  CatalogProductCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 21/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

extension Date {
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2)
//        return date1.compare(self as Date) == self.compare(date2 as Date)
    }
}

import UIKit

class CatalogProductCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var newLabelImageView: UIImageView!
    @IBOutlet weak var productInfoLabel: UILabel!
    @IBOutlet weak var discountButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        discountButton.titleLabel?.textAlignment = .center
        discountButton.isHidden = true
        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true
    }
    
    func configure(viewModel: CatalogViewModel?, indexPath: IndexPath) {
        if let catalogViewModel = viewModel {
            if let product = catalogViewModel.products.value?[indexPath.row] {
                productInfoLabel.attributedText = catalogViewModel.getProductInfoOf(product, cellWidth: self.frame.size.width)
                productInfoLabel.textAlignment = .center
                newLabelImageView.isHidden = true
                
                // set new label by checking current date lies between two dates (new_from_date & new_to_date)
                if let newFromDateString = product.customAttributes?.filter({$0.attributeCode == "news_from_date"}).first?.value, let newToDateString = product.customAttributes?.filter({$0.attributeCode == "news_to_date"}).first?.value {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                    if let newFromDate = formatter.date(from: newFromDateString), let newToDate = formatter.date(from: newToDateString) {
                        if Date().isBetweeen(date: newFromDate, andDate: newToDate) {
                            newLabelImageView.isHidden = false
                        }
                    }
                }
            
                if let discount = catalogViewModel.calculateDiscount(product), Double(discount) != 0 {
                    discountButton.isHidden = false
                    discountButton.setTitle("\(discount)%", for: .normal)
                } else {
                    discountButton.isHidden = true
                }
                
                tagLabel.isHidden = true
                if let tagValue = product.extensionAttributes?.tagValue {
                    tagLabel.text = tagValue
                    tagLabel.font = FontUtility.mediumFontWithSize(size: 12.0)
                    tagLabel.adjustsFontSizeToFitWidth = true
                    tagLabel.backgroundColor = #colorLiteral(red: 0.9907594713, green: 0.9980752698, blue: 1, alpha: 0.8025693222)
                    tagLabel.isHidden = false
                }
                
                let thumbnail = product.images?.filter({$0.types.count > 0}).first
                if let thumbnailImage = thumbnail?.file, !thumbnailImage.isEmpty, let urlStringImage = AppConfigurationModel.sharedInstance.productMediaUrl {
                    
                    if let urlString = (urlStringImage + thumbnailImage).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                
                        let request = URLRequest(url: url)
                        DispatchQueue.global(qos: .background).async {
                           self.productImageView.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                                DispatchQueue.main.async(execute: {
                                    self.productImageView.alpha = 0.0
                                    self.productImageView.image = image
                                    UIView.animate(withDuration: 0.5, animations: {self.productImageView.alpha = 1.0})
                                })
                            }, failure: nil)
                        }
                    } else {
                        productImageView.image = Image.placeholder
                    }
                } else {
                    productImageView.image = Image.placeholder
                }
            }
        }
    }
}
