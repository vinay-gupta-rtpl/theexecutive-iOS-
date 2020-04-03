//
//  WearWithTableViewCell.swift
//  ProjectDetailDemo
//
//  Created by Himani Sharma on 20/03/18.
//  Copyright © 2018 Himani Sharma. All rights reserved.
//

import UIKit

class WearWithTableViewCell: UITableViewCell {

    @IBOutlet weak var wearWithLabel: UILabel!
    @IBOutlet weak var wearWithCollection: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
