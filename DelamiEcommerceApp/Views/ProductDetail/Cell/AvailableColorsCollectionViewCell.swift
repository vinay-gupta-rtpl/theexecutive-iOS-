//
//  AvailableColorsCollectionViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Roshan Singh on 4/17/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class AvailableColorsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    var availableColorsData: String? {
        didSet {
            productNameLabel.text = availableColorsData
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productImageView.contentMode = .scaleAspectFill
        self.productImageView.clipsToBounds = true
    }
    
    var imageUrl: String? {
        didSet {
            if let imageUrlString = imageUrl, !imageUrlString.isEmpty, let  productMediaURL = AppConfigurationModel.sharedInstance.productMediaUrl {
                
                if let urlString = (productMediaURL + imageUrlString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
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
                    self.productImageView.image = Image.placeholder
                }
            } else {
                self.productImageView.image = Image.placeholder
            }
        }
    }
}
