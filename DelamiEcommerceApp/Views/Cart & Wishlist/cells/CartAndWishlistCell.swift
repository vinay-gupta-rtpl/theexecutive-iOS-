//
//  CartAndWishlistCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

/**
 define type to identify same cell in diffrent cases
 
 - shoppingBag: table view cell for shopping bag item
 - wishlist: table view cell for wishlist item
 
 */

enum CellType {
    case shoppingBag
    case wishlist
}
// MARK: - Wishlist Protocol
protocol WishlistCall: class {
    func tappedOnWishlistRemoveButton(index: Int?)
    func tappedOnWishlistMoveToCartButton(index: Int?)
    func navigateToProductDetail(index: Int?)
}

// MARK: - Shopping bag Protocol
protocol ShoppingBagCall: class {
    func tappedOnRemoveButton(index: Int?)
    func tappedOnMoveCartToWishlist(index: Int?)
    func tappedOnUpdateQuantityButton(index: Int?, updateType: UpdateQuantityType?, quantity: Int64?)
    func navigateToProductDetailPage(index: Int?)
}

// MARK: - Class
class CartAndWishlistCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var colorAndSizeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cartOrWishlistButton: UIButton!
    @IBOutlet weak var quantityDecreaseButton: UIButton!
    @IBOutlet weak var quantityIncreaseButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var availableProductLabel: UILabel!
    @IBOutlet weak var outOfStockTransparentView: UIView!
    @IBOutlet weak var outOfStockStackView: UIStackView!
    @IBOutlet weak var propertiesStackView: UIStackView!
    @IBOutlet weak var changeQuantityStack: UIStackView!
    
    // MARK: - Wishlist and Shopping bag Delegate
    weak var wishlistCallDelegate: WishlistCall?
    weak var shoppingBagCallDelegate: ShoppingBagCall?
    
    var cellType: CellType = .shoppingBag
    var cartitem: ShoppingBagModel?
    var decreaseQtyLocally: Bool = false
    
    // MARK: - Cell Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Wishlish Cell Setup Methods
    /**
     Setup wishlist item cell
     
     - parameter wishlistItem: object reference of WishlistItemModel(have the information of item received from API)
     
     */
    
    //    {
    //    var priceText = "IDR " + regularPrice.changeStringToINR()
    //    var attPrice = NSMutableAttributedString(string: priceText)
    //
    //    if !specialPrice.isEmpty {
    //    priceText += " IDR \(specialPrice.changeStringToINR())"
    //
    //    attPrice = NSMutableAttributedString(string: priceText)
    //    if let priceRange = priceText.range(of: "IDR \(regularPrice.changeStringToINR())")?.nsRange {
    //    attPrice.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 12.0), range: priceRange)
    //    attPrice.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: priceRange)
    //    }
    //
    //    if let priceRange = priceText.range(of: "IDR \(specialPrice.changeStringToINR())")?.nsRange {
    //    attPrice.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 15.0), range: priceRange)
    //    attPrice.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: priceRange)
    //    }
    //    return attPrice
    //    }
    //    return attPrice
    //    }
    
    func configureWishlistCell(wishlistItem: WishlistItemModel?) {
        if wishlistItem?.type == .configurable {
            cartOrWishlistButton.setImage(#imageLiteral(resourceName: "eye"), for: .normal)
        } else { // in case of simple
            cartOrWishlistButton.setImage(#imageLiteral(resourceName: "bag_icon"), for: .normal)
        }
        changeQuantityStack.isHidden = true
        propertiesStackView.spacing = 20.0
        
        // adding tap gestures to product name and image, so we can redirect it to product detail
        productImageView.isUserInteractionEnabled = true
        productName.isUserInteractionEnabled = true
        
        self.tapGestureOnProductImageOrName()
        
        if let item = wishlistItem {
            productName.text = item.name?.uppercased() ?? ""
            if let sku = item.sku {
                skuLabel.text = ConstantString.sku.localized() + " " + sku
            }
            
            //            if let color = wishlistItem?.options?.filter({($0.label ?? "") == "Color"}).first?.value, let size = wishlistItem?.options?.filter({($0.label ?? "") == "Size"}).first?.value {
            //                colorAndSizeLabel.isHidden = false
            //                let colorAndSizeString = color + "  |  " + size
            //                let stringToColor = "  |  "
            //                let range = (colorAndSizeString as NSString).range(of: stringToColor)
            //                let attributedString = NSMutableAttributedString(string: colorAndSizeString)
            //                attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray, range: range)
            //                colorAndSizeLabel.attributedText = attributedString
            //
            //                // if any one of parameter will not come then " | " won't append.
            //                if color == "" || size == "" {
            //                    colorAndSizeLabel.text = colorAndSizeLabel.text?.replacingOccurrences(of: "  |  ", with: "")
            //                }
            //            } else {
            //            }
            
            colorAndSizeLabel.text = ""
            colorAndSizeLabel.isHidden = true
            
            var regularPrice = ""
            var specialPrice = ""
            if let regular = wishlistItem?.regularPrice {
                regularPrice = String(regular)
                if let special = wishlistItem?.specialPrice, !regular.isEqual(to: special) {
                    specialPrice = String(special)
                }
            }
            priceLabel.attributedText = Utils().createPriceAttribueString(regularPrice: regularPrice, specialPrice: specialPrice)
            setUpImage(imageUrl: item.imageURL)
            
            // out of stock
            if let isInStock = item.stockInfo?.isInStock {
                if !isInStock { // not in stock
                    self.outOfStockForWishlist(hideAndInteractionProperty: false, item: item)
                    
                } else {
                    self.outOfStockFunctionality(hideAndInteraction: true)
                }
            }
        }
    }
    
    /**
     Download and show product image
     
     - parameter imageUrl: url to download the image
     
     */
    func setUpImage(imageUrl: String?) {
        guard let imageString = imageUrl, let imgPath = AppConfigurationModel.sharedInstance.productMediaUrl, let url = URL(string: (imgPath + imageString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" ) else {
            self.productImageView.image = Image.placeholder
            return
        }
        
        let request = URLRequest(url: url)
        DispatchQueue.global(qos: .background).async {
            
            self.productImageView.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                DispatchQueue.main.async(execute: {
                    self.productImageView.alpha = 0.0
                    self.productImageView.image = image
                    self.productImageView.contentMode = .scaleAspectFit
                    UIView.animate(withDuration: 0.5, animations: {self.productImageView.alpha = 1.0})
                })
            }, failure: nil)
        }
    }
    
    // MARK: - Shopping bag Cell Setup Methods
    
    /**
     Setup wishlist item cell
     
     - parameter wishlistItem: object reference of WishlistItemModel(have the information of item received from API)
     
     */
    
    func configureShoppingBagCell(shoppingBagItem: ShoppingBagModel?) {
        cartOrWishlistButton.setImage(Image.wishlistIconForCartScreen, for: .normal)
        
        if let item = shoppingBagItem {
            self.cartitem = item
            productName.text = item.name.uppercased()
            skuLabel.text = ConstantString.sku.localized() + " " + (item.productType == "configurable" ? (item.productExtentionAttribute?.configurableSKU ?? "") : item.skuId)
            
            let color =  getProductOptions(item: item, optionType: .color)
            let size =  getProductOptions(item: item, optionType: .size)
            let colorAndSizeString = color + "  |  " + size
            let stringToColor = "  |  "
            let range = (colorAndSizeString as NSString).range(of: stringToColor)
            let attributedString = NSMutableAttributedString(string: colorAndSizeString)
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray, range: range)
            
            //            colorAndSizeLabel.text =  colorAndSizeString
            //            var colorAndSize = NSMutableAttributedString(string: colorAndSizeString)
            //            if let priceRange = colorAndSizeString.range(of: " | ")?.nsRange {
            //                colorAndSize.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 15.0), range: priceRange)
            //                colorAndSize.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: priceRange)
            //            }
            colorAndSizeLabel.attributedText = attributedString
            
            // if any one of parameter will not come then " | " won't append.
            if color == "" || size == "" {
                colorAndSizeLabel.text = colorAndSizeLabel.text?.replacingOccurrences(of: "  |  ", with: "")
            }
            
            if color == "" && size == "" {
                colorAndSizeLabel.isHidden = true
            }
            
            // adding tap gestures to product name and image, so we can redirect it to product detail
            productImageView.isUserInteractionEnabled = true
            productName.isUserInteractionEnabled = true
            
            self.tapGestureOnProductImageOrName()
            
            // price should be multiplied by quantity
            var regularPrice = ""
            var specialPrice = ""
            if let regular = item.productExtentionAttribute?.regularPrice {
                regularPrice = String(regular * Double(item.quantity))
                
                if let special = item.specialPrice, !regular.isEqual(to: special), !special.isEqual(to: 0.0) {
                    specialPrice = String(special * Double(item.quantity))
                }
            }
            priceLabel.attributedText = Utils().createPriceAttribueString(regularPrice: regularPrice, specialPrice: specialPrice)
            
            self.quantityLabel.text = String(item.quantity)
            setUpImage(imageUrl: item.productExtentionAttribute?.productImage)
            
            if let isInStock = item.productExtentionAttribute?.stockInfo?.isInStock, let stockQuantity = item.productExtentionAttribute?.stockInfo?.quantity {
                if isInStock && stockQuantity < item.quantity {
                    //                    self.decreaseQtyLocally = true
                    self.availableProductLabel.text = ConstantString.only.localized() + " " + String(stockQuantity) + " " + ConstantString.productAvailable.localized()
                    self.quantityIncreaseButton.isUserInteractionEnabled = false
                    
                } else {
                    self.availableProductLabel.text = ""
                    self.quantityIncreaseButton.isUserInteractionEnabled = true
                    //                    self.decreaseQtyLocally = false
                }
                
                if !isInStock {
                    self.outOfStockFunctionality(hideAndInteraction: false)
                } else {
                    self.outOfStockFunctionality(hideAndInteraction: true)
                }
            }
        }
    }
    
    // Out of stock functaionality that quantity increase/ decrease and out of stock view hide and show.
    func outOfStockFunctionality(hideAndInteraction: Bool) {
        self.outOfStockStackView.isHidden = hideAndInteraction
        self.outOfStockTransparentView.isHidden = hideAndInteraction
        self.quantityIncreaseButton.isUserInteractionEnabled = hideAndInteraction
        self.quantityDecreaseButton.isUserInteractionEnabled = hideAndInteraction
    }
    
    func outOfStockForWishlist(hideAndInteractionProperty: Bool, item: WishlistItemModel) {
        self.outOfStockStackView.isHidden = hideAndInteractionProperty
        self.quantityIncreaseButton.isUserInteractionEnabled = hideAndInteractionProperty
        self.quantityDecreaseButton.isUserInteractionEnabled = hideAndInteractionProperty
        
        if item.type == .simple {
            self.cartOrWishlistButton.isUserInteractionEnabled = hideAndInteractionProperty
            self.outOfStockTransparentView.isHidden = hideAndInteractionProperty
        } else {
            self.cartOrWishlistButton.isUserInteractionEnabled = !hideAndInteractionProperty
            self.outOfStockTransparentView.isHidden = !hideAndInteractionProperty
        }
    }
    
    // Get color and size value using filter
    func getProductOptions(item: ShoppingBagModel, optionType: OptionType) -> String {
        return item.productOption?.productExtentionAttribute?.colorSizeConfigOption?.filter({($0.extensionAttributes?.colorSizeOptionLabel ?? "") == optionType.rawValue}).first?.extensionAttributes?.colorSizeOptionValue ?? ""
    }
    
    // add tap gesture on product name and image
    func tapGestureOnProductImageOrName() {
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(tapOnProductNameOrImage(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        
        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(tapOnProductNameOrImage(_:)))
        tapGestureName.numberOfTapsRequired = 1
        
        productName.addGestureRecognizer(tapGestureName)
        productImageView.addGestureRecognizer(tapGestureImage)
    }
    
    // MARK: - Button Actions
    @IBAction func tapOnCartOrWishlistButton(_ sender: UIButton) {
        self.cartOrWishlistButton.isUserInteractionEnabled = false
        if cellType == .wishlist {
            wishlistCallDelegate?.tappedOnWishlistMoveToCartButton(index: self.tag)
            self.cartOrWishlistButton.isUserInteractionEnabled = true
        } else if cellType == .shoppingBag {
            // Move Item from Cart to Wishlist
            shoppingBagCallDelegate?.tappedOnMoveCartToWishlist(index: self.tag)
            self.cartOrWishlistButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func tapOnRemoveButton(_ sender: UIButton) {
        if cellType == .wishlist {
            wishlistCallDelegate?.tappedOnWishlistRemoveButton(index: self.tag)
        } else if cellType == .shoppingBag {
            shoppingBagCallDelegate?.tappedOnRemoveButton(index: self.tag)
        }
    }
    
    @IBAction func tapOnDecrease(_ sender: UIButton) {
        if cellType == .shoppingBag {
            var updatedQuantity: Int64 = 1
            if let quantity = self.quantityLabel.text {
                updatedQuantity =  Int64(quantity) == 1 ? 1 : Int64(quantity)! - 1
            }
            /* when in stock there are less product than item quantity of product, then locally decreade item till when it reaches to the in stock limit or less and then API call else locally decrease item quantity but not call the API. */
            if let item = self.cartitem, let stockQuantity = item.productExtentionAttribute?.stockInfo?.quantity {
                if availableProductLabel.text != "" {
                    self.quantityLabel.text = String(stockQuantity)
                    updatedQuantity = stockQuantity
                }
                
                if Int(self.quantityLabel.text!) != 1 || stockQuantity == 1 {
                    // 1st condition for --- if quantity is 1 no need to call api again and again on clicking this button.
                    // 2nd condition for ---- when only one quantity in stock and in cart if more quantity present then decrease quantity and when it shows 1 (because only one quantity available then this block will call)
                    shoppingBagCallDelegate?.tappedOnUpdateQuantityButton(index: self.tag, updateType: .decrease, quantity: updatedQuantity)
                }
            }
        }
    }
    
    @IBAction func tapOnIncrease(_ sender: UIButton) {
        if cellType == .shoppingBag {
            var updatedQuantity: Int64 = 1
            if let quantity = self.quantityLabel.text {
                updatedQuantity = Int64(quantity)! + 1
            }
            
            shoppingBagCallDelegate?.tappedOnUpdateQuantityButton(index: self.tag, updateType: .increase, quantity: updatedQuantity)
        }
    }
    
    @objc func tapOnProductNameOrImage(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            if cellType == .wishlist {
                wishlistCallDelegate?.navigateToProductDetail(index: view.tag)
            } else {
                shoppingBagCallDelegate?.navigateToProductDetailPage(index: view.tag)
            }
        }
    }
}
