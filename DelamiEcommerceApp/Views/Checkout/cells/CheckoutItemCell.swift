//
//  CheckoutItemCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CheckoutItemCell: UITableViewCell {
    @IBOutlet weak var checkoutItemCollectionView: UICollectionView!
    
    var cartItems: [ShoppingBagModel]? {
        didSet {
            checkoutItemCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        checkoutItemCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension CheckoutItemCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.CheckoutAndOther.checkoutProduct, for: indexPath)
        if let imageView = cell.viewWithTag(201) as? UIImageView, let item = cartItems?[indexPath.row] {
            if let imageString = item.productExtentionAttribute?.productImage, let imgPath = AppConfigurationModel.sharedInstance.productMediaUrl, let url = URL(string: (imgPath + imageString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                let request = URLRequest(url: url)
                DispatchQueue.global(qos: .background).async {
                    imageView.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                        DispatchQueue.main.async(execute: {
                            imageView.image = image
                            imageView.clipsToBounds = true
                            imageView.contentMode = .scaleAspectFit
                        })
                    }, failure: nil)
                }
            } else {
                imageView.image = Image.placeholder
            }
        }
        
        if let itemInfoLabel = cell.viewWithTag(202) as? UILabel, let item = cartItems?[indexPath.row] {
            itemInfoLabel.textAlignment = .center
            itemInfoLabel.numberOfLines = 0
            itemInfoLabel.font = FontUtility.regularFontWithSize(size: 13.0)
            itemInfoLabel.text = item.name + SystemConstant.newLine + ConstantString.qty.localized() + ": " + "\(item.quantity)"
        }
        return cell
    }
}

extension CheckoutItemCell {
    func setUpImageCell(item: ShoppingBagModel, imageView: UIImageView?) {
    }
}
