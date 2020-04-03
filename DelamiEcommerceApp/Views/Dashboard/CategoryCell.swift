//
//  CategoryCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 13/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    // IBOutlet declaration
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var leadingCategoryNameConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
