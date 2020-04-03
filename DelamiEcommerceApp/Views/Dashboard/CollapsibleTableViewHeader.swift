//
//  CollapsibleTableViewHeader.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 13/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate: class {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let imageView = UIImageView()
    
    weak var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleLabel.font = FontUtility.boldFontWithSize(size: 17.0)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureRecognizer:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(header: self, section: cell.section)
    }
}
