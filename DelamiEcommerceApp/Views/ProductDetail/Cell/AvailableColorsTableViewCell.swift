//
//  AvailableColorsTableViewCell.swift
//  ProjectDetailDemo
//
//  Created by Himani Sharma on 20/03/18.
//  Copyright © 2018 Himani Sharma. All rights reserved.
//

import UIKit

protocol SendCollectionIndexPath: class {
    func sendProductModalAndIndexPath(rowNumber: Int)
}

class AvailableColorsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var availableColorLabel: UILabel!
    @IBOutlet weak var availableColorCollection: UICollectionView!

//    var viewModel: [ProductDetailModel]?
    var viewModel: ProductDetailViewModel!
    weak var sendColletionIndexPath: SendCollectionIndexPath?

    var isItFirstAppereance: Bool?
    var itemSelected = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateStringsForApplicationGlobalLanguage()
    }

    func reloadData() {
        availableColorCollection.delegate = self
        availableColorCollection.dataSource = self
        availableColorCollection.reloadData()
        availableColorCollection.isScrollEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension AvailableColorsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return (viewModel?.count)!
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != itemSelected else {
            return
        }
        sendColletionIndexPath?.sendProductModalAndIndexPath(rowNumber: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120.0, height: 125.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let _ = collectionViewLayout as? UICollectionViewFlowLayout {
            let padding = ((collectionView.frame.width - 120.0) / 2)
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ProductDetail.colorCollection, for: indexPath) as? AvailableColorsCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == itemSelected {
            cell.productImageView.layer.borderWidth = 0.8
            cell.productImageView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        } else {
            cell.productImageView.layer.borderWidth = 0.0
            cell.productImageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        }
        cell.productNameLabel.text = viewModel.colorOptions?.first?.name
        cell.productNameLabel.adjustsFontSizeToFitWidth = true
        cell.imageUrl = viewModel.productModel?.images?.filter({$0.types.count > 0}).first?.file
        return cell
    }
    
}

//extension AvailableColorsTableViewCell {
//    func getProductImageArray(productArray: [ProductModel]) -> [[String: [ProductImage]]] {
//        var imageArray: [[String: [ProductImage]]] = []
//        for productModalObj in productArray {
//            for customAttributeModal in productModalObj.customAttributes! where customAttributeModal.attributeCode == "color" {
//                let filtered = imageArray.filter { (dict) -> Bool in
//                    dict.keys.contains(customAttributeModal.value!)
//                }
//                if filtered.count == 0 {
//                    var imageDict: [String: [ ProductImage]] = [:]
//                    imageDict[customAttributeModal.value!] = productModalObj.images
//                    imageArray.append(imageDict)
//                }
//            }
//        }
//        return imageArray
//    }
//
//}
