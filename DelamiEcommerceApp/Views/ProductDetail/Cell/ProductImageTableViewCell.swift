//
//  ProductImageTableViewCell.swift
//  ProjectDetailDemo
//
//  Created by Himani Sharma on 20/03/18.
//  Copyright © 2018 Himani Sharma. All rights reserved.
//

import UIKit

class ProductImageTableViewCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet weak var productImage: UIImageView!
    
    var setUpAction = ProductModel() {
        didSet {
            
        }
    }
    
    func setUpImageCell(productData: ProductDataModel) {

        if productData.image != nil {
            showImage(productData.image!)

        } else {
            guard let imageString = productData.imageURL, let imgPath = AppConfigurationModel.sharedInstance.productMediaUrl, let url = URL(string: (imgPath + imageString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" ) else {
                self.productImage.image = Image.placeholder
                return
            }

            let request = URLRequest(url: url)
            DispatchQueue.global(qos: .background).async {

                self.productImage.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.showImage(image)
                    })
                }, failure: nil)
            }
        }
    }

    func showImage(_ img: UIImage) {
        self.productImage.alpha = 0.0
        self.productImage.image = img
        
        UIView.animate(withDuration: 0.5, animations: {self.productImage.alpha = 1.0})
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
