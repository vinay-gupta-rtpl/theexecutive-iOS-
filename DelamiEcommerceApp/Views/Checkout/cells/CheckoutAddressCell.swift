//
//  CheckoutAddressCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CheckoutAddressCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(addressInfo: InfoAddress) {
        nameLabel.text = addressInfo.firstname + " " + addressInfo.lastname
        addressLabel.text = getCompleteAddressString(addressInfo: addressInfo)
        mobileNumberLabel.text = addressInfo.telephone
    }
    
    func getCompleteAddressString(addressInfo: InfoAddress) -> String {
        var finalAddress: String = ""
        if let streetCount = addressInfo.street?.count, streetCount > 1, let firstAddress = addressInfo.street?.first, let lastAddress = addressInfo.street?.last {
            finalAddress = firstAddress + " " + lastAddress + ""
        } else if let firstAddress = addressInfo.street?.first {
            finalAddress = firstAddress + " "
        }
        
        if let regionName = addressInfo.region?.regionName {
            finalAddress += " " + regionName
        }
        
        if let cityName = addressInfo.city {
            finalAddress += " " + cityName
        }
        
        if let postCode = addressInfo.postcode {
            finalAddress += " " + postCode
        }
        
        finalAddress += ", " + SystemConstant.defaultCountry.localized()
        return finalAddress
    }
}
