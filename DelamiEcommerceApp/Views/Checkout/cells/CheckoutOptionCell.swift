//
//  CheckoutOptionCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

protocol CheckoutPaymentOptionsCall: class {
    func tappedOnCheckbox(at index: Int)
}

class CheckoutOptionCell: UITableViewCell {
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    
    weak var delegate: CheckoutPaymentOptionsCall?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func shippingOrPaymentOptionSelected(_ sender: UIButton) {
        delegate?.tappedOnCheckbox(at: sender.tag)
    }
}
