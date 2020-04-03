//
//  ButtonTableViewCell.swift
//  ProjectDetailDemo
//
//  Created by Himani Sharma on 20/03/18.
//  Copyright © 2018 Himani Sharma. All rights reserved.
//

import UIKit

protocol ButtonCellProtocols: class {
    func openSafariwithUrl (url: String, title: String?)
    func shareLink()
    func openChat()
}

class ButtonTableViewCell: UITableViewCell {
    // MARK: - Delegate
    weak var idStaticButtonDelegate: ButtonCellProtocols!
    var staticUrl: ProductStaticUrl?
    var addToWishListButtonHandler: (() -> Void)?
    
    func setUpCell(productStaticURL: ProductStaticUrl) {
        self.staticUrl = productStaticURL
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.updateStringsForApplicationGlobalLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapOnCompositionAndCare(_ sender: Any) {
        self.idStaticButtonDelegate?.openSafariwithUrl(url: (staticUrl?.compositionAndCare)!, title: NavigationTitle.customerAndCare.localized())
    }
    
    @IBAction func tapOnSizeGuideline(_ sender: Any) {
         self.idStaticButtonDelegate?.openSafariwithUrl(url: (staticUrl?.sizeGuideline)!, title: NavigationTitle.sizeGuideline.localized())
    }
    
    @IBAction func tapOnShippingButton(_ sender: Any) {
         self.idStaticButtonDelegate?.openSafariwithUrl(url: (staticUrl?.shipping)!, title: NavigationTitle.shipping.localized())
    }
    
    @IBAction func tapOnReturnButton(_ sender: Any) {
        self.idStaticButtonDelegate?.openSafariwithUrl(url: (staticUrl?.returns)!, title: NavigationTitle.returns.localized())
    }
    
    @IBAction func tapOnShareButton(_ sender: Any) {
        self.idStaticButtonDelegate?.shareLink()
    }
    
    @IBAction func tapOnBuyingGuidelines(_ sender: Any) {
         self.idStaticButtonDelegate?.openSafariwithUrl(url: (staticUrl?.buyingGuideline)!, title: NavigationTitle.buyingGuidelines.localized())
    }
    
    @IBAction func tapOnChatButton(_ sender: Any) {
        self.idStaticButtonDelegate?.openChat()
    }
    
    @IBAction func tapOnAddToWishlist(_ sender: Any) {
        addToWishListButtonHandler?()
    }
}
