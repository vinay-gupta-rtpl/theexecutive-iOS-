//
//  MyOrderTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/11/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

protocol MyOrderTableCellDelegate: class {
    func returnButtonAction(indexPath: IndexPath)
}

class MyOrderTableViewCell: UITableViewCell {
    var cellIndex: IndexPath?
    weak var orderCellDelegate: MyOrderTableCellDelegate?
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var dateOfOrderLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productIdLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        returnButton.layer.borderWidth = 1.0
        returnButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        returnButton.layer.cornerRadius = 2.0
        self.bringSubview(toFront: returnButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setUpData(myOrderModel: MyOrderModel) {
        dateOfOrderLabel.text = dateFormatter(date: myOrderModel.dateOfOrder)
        guard let price = myOrderModel.price else {
            return
        }
        priceLabel.attributedText = Utils().createPriceAttribueString(regularPrice: price, specialPrice: "")
        productIdLabel.text = myOrderModel.productId
        statusLabel.text = myOrderModel.status
        if let mediaURL = AppConfigurationModel.sharedInstance.productMediaUrl {
            if let urlString = (mediaURL + "\(myOrderModel.imageURL ?? "")").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString ) {
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
            }
        } else {
            productImageView.image = Image.placeholder
        }
        
        setUpReturnButton(returnPossible: myOrderModel.isRefundable!)
    }
    
    @IBAction func returnButtonAction(_ sender: UIButton) {
        if let index = cellIndex {
            orderCellDelegate?.returnButtonAction(indexPath: index)
        }
    }
}

extension MyOrderTableViewCell {
    func setUpReturnButton(returnPossible: Bool) {
        if !returnPossible {
            returnButton.isEnabled = false
            returnButton.isHidden = true
        } else {
            returnButton.isEnabled = true
            returnButton.isHidden = false
        }
    }
    
    func dateFormatter(date: String) -> String {
        //        2018-05-15 13:39:05
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFromString = dateFormatter.date(from: date)      // "Nov 25, 2015, 4:31 AM" as NSDate
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = SystemConstant.dateFormatterPattern.localized() // "dd-MM-yyyy"
        
        return dateFormatter2.string(from: dateFromString!) // "Nov 25, 2015" as String
    }
    
}
