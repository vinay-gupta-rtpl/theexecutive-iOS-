//
//  OrderDetailTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/15/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productSizeLabel: UILabel!
    @IBOutlet weak var productColourLabel: UILabel!
    @IBOutlet weak var productSkuIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var sepratorbwColorSize: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(productModel: OrderProductModel) {
        if let itemName = productModel.name, let itemPrice = productModel.price, let itemSKU = productModel.sku {
            productNameLabel.text = itemName.uppercased()
            productSkuIdLabel.text = ConstantString.sku.uppercased().localized() + " " + itemSKU
            productPriceLabel.attributedText = Utils().createPriceAttribueString(regularPrice: String(itemPrice), specialPrice: "")
        }

        guard let itemOptions = productModel.extensionAttribute else { return }
        if let imageURL = itemOptions.imageURL {
            setImage(imageURL: imageURL)
        }
        if let color = itemOptions.options?.filter({($0.label ?? "") == "Color"}).first?.value {
            productColourLabel.text = color
            sepratorbwColorSize.isHidden = false
        } else {
            sepratorbwColorSize.isHidden = true
        }
        if let size = itemOptions.options?.filter({($0.label ?? "") == "Size"}).first?.value {
            productSizeLabel.text = size
        }
        productQuantityLabel.text = "\(productModel.qty ?? 1) " + "item(s)".localized()
    }

    func setImage(imageURL: String) {
        if let urlString = (AppConfigurationModel.sharedInstance.productMediaUrl! + "\(imageURL)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString ) {
            let request = URLRequest(url: url)
            DispatchQueue.global(qos: .background).async {
                self.productImage.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.productImage.alpha = 0.0
                        self.productImage.image = image
                        UIView.animate(withDuration: 0.5, animations: {self.productImage.alpha = 1.0})
                    })
                }, failure: nil)
            }
        } else {
            productImage.image = Image.placeholder
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
