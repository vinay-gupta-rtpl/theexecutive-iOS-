//
//  AddressBookTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

protocol AddressBookCellProtocols: class {
    func showAlert()
    func removeAddress(atIndex: Int)
    func editAddress(atIndex: Int)
    func setDefaultAddress(atIndex: Int)
}

class AddressBookTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    
    @IBOutlet weak var addressDefaultLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var setAsDefaultButton: UIButton!
    
    // MARK: - Delegates
     weak var idAddressBookDelegate: AddressBookCellProtocols!
    
    func setUpCell(addressInfo: InfoAddress, atIndex: Int) {
        
        removeButton.tag = atIndex
        editButton.tag = atIndex
        
        nameLabel.text = addressInfo.firstname + " " + addressInfo.lastname
        
        var streetAddress: String = ""
        var postalCode = ""
        if let streetCount = addressInfo.street?.count, streetCount > 1 {
            streetAddress = (addressInfo.street?.first)! + ", " + (addressInfo.street?.last)!
        } else {
             streetAddress = (addressInfo.street?.first)!
        }
        
        if let cityName = addressInfo.city {
            streetAddress += ", " + cityName
        }
        
        if let regionName = addressInfo.region?.regionName {
            streetAddress += ", " + regionName
        }
        
        if let postCode = addressInfo.postcode {
            postalCode = ", " + postCode
        }
        
        addressLabel.text = streetAddress + postalCode + ", " + SystemConstant.defaultCountry.localized()
        mobileNumberLabel.text = addressInfo.telephone
        
        guard addressInfo.defaultShipping != nil, addressInfo.defaultShipping == true else {
            setAsDefaultButton.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
            return
        }
        setAsDefaultButton.setImage(#imageLiteral(resourceName: "check_grey"), for: .normal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setAsDefaultAction(_:)))
        tapGesture.delegate = self
        addressDefaultLabel.addGestureRecognizer(tapGesture)

        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeButtonAction(_ sender: Any) {
        if setAsDefaultButton.currentImage == #imageLiteral(resourceName: "check_grey") {
           // Alert Show
             self.idAddressBookDelegate?.showAlert()
        } else {
            // Remove Functionality
            self.idAddressBookDelegate?.removeAddress(atIndex: removeButton.tag)
        }
    }

    @IBAction func editButtonAction(_ sender: Any) {
         self.idAddressBookDelegate?.editAddress(atIndex: editButton.tag)
    }
    
    @IBAction func setAsDefaultAction(_ sender: Any) {
        if setAsDefaultButton.currentImage == #imageLiteral(resourceName: "check_grey") {
            // Alert Show
//            self.idAddressBookDelegate?.showAlert()
        } else {
            setAsDefaultButton.setImage(#imageLiteral(resourceName: "check_grey"), for: .normal)
            self.idAddressBookDelegate?.setDefaultAddress(atIndex: editButton.tag)
        }
    }
}
