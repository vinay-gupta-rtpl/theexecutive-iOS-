//
//  ReturnModeTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 29/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
protocol ReturnOrderCall: class {
    func orderReturnAction(selectedMode: String)
}

enum ReturnMode: String {
    case alphamart = "alfatrex"
    case courier
}

class ReturnModeTableViewCell: UITableViewCell {
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var courierModeButton: UIButton!
    @IBOutlet weak var alphamartModeButton: UIButton!
    
    var selectedMode: ReturnMode = .courier
    weak var delegate: ReturnOrderCall?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        courierModeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        alphamartModeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        selectedMode = .courier
        courierModeButton.isSelected = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapOnSelectReturnMode(_ sender: UIButton) {
        sender.isSelected = true
        if sender == courierModeButton {
            alphamartModeButton.isSelected = false
            selectedMode = .courier
        } else {
            courierModeButton.isSelected = false
            selectedMode = .alphamart
        }
    }
    
    @IBAction func orderReturnAction(_ sender: UIButton) {
        delegate?.orderReturnAction(selectedMode: selectedMode.rawValue)
    }
}
