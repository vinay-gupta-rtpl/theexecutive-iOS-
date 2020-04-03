//
//  OrderReturnTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/15/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class OrderReturnTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedButton: UIButton!
    //    @IBOutlet weak var reasonPicker: UITextField!
    @IBOutlet weak var reasonPicker: BindingTextfield!
    
    var pickerView = UIPickerView()
    let toolbar = UIToolbar()
    var qty: Int  = 0
    var toolbarView = UIView()
    
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var itemQtyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productSizeLabel: UILabel!
    @IBOutlet weak var productColorLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var mobileNoToLabel: UILabel!
    @IBOutlet weak var addressToLabel: UILabel!
    @IBOutlet weak var mobileNoFromLabel: UILabel!
    @IBOutlet weak var addressFromLabel: UILabel!
    @IBOutlet weak var nameFromLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameToLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    
    @IBOutlet weak var returnFromView: UIView!
    @IBOutlet weak var returnToView: UIView!
    //    @IBOutlet weak var addressView: UIView!
    
    //    var reason: [String] = [ReturnReason.badQuality.rawValue.localized(), ReturnReason.notAccordance.rawValue.localized(), ReturnReason.other.rawValue.localized()]
    
    var reason: [String] = [ReturnReason.productNotFit.rawValue.localized(), ReturnReason.incorrectProduct.rawValue.localized(), ReturnReason.notMatchDescription.rawValue.localized(), ReturnReason.notMeetExpectation.rawValue.localized(), ReturnReason.qualityIssue.rawValue.localized()]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if self.reuseIdentifier == CellIdentifier.Order.itemDetail {
            setView()
        }
    }
    
    func setView() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 9, width: 12, height: 12))
        imageView.image = #imageLiteral(resourceName: "down_arrow")
        imageView.contentMode = .scaleAspectFit
        paddingView.addSubview(imageView)
        reasonPicker.rightView = paddingView
        reasonPicker.rightView?.isUserInteractionEnabled = false
        reasonPicker.rightViewMode = .always
        
        reasonPicker.layer.borderWidth = 0.7
        reasonPicker.placeHolderColor = #colorLiteral(red: 0.4274509804, green: 0.4235294118, blue: 0.4274509804, alpha: 1)
        pickerView.delegate = self
        reasonPicker.tintColor = .clear
        reasonPicker.inputView = pickerView
        reasonPicker.layer.cornerRadius = 5.0
    }
    
    func setData() {
        returnToView.layer.cornerRadius = 5.0
        returnFromView.layer.cornerRadius = 5.0
        if let shippingAddress = orderDetailModel?.extensionAttributes?.formattedShippingAddress {
            nameFromLabel.text = shippingAddress.firstname + " " + shippingAddress.lastname
            emailLabel.text = orderDetailModel?.email
            setUpAddress(addressInfo: shippingAddress)
            mobileNoFromLabel.text = shippingAddress.telephone
        }
        
        if let returnAddress = orderDetailModel?.extensionAttributes?.returnToAddress {
            nameToLabel.text = returnAddress.returnToName
            addressToLabel.text = returnAddress.returnToAddress
            mobileNoToLabel.text = returnAddress.returnToContact
        }
    }
    
    func setUpAddress(addressInfo: InfoAddress) {
        var streetAddress: String = ""
        var postalCode = ""
        if let streetCount = addressInfo.street?.count, streetCount > 1 {
            streetAddress = (addressInfo.street?.first)! + " " + (addressInfo.street?.last)! + ""
        } else {
            streetAddress = (addressInfo.street?.first)! + " "
        }
        if let regionName = addressInfo.region?.regionName {
            streetAddress += " " + regionName
        }
        if let cityName = addressInfo.city {
            streetAddress += " " + cityName
        }
        if let postCode = addressInfo.postcode {
            postalCode = " " + postCode
        }
        
        addressFromLabel.text = streetAddress + postalCode + ", " + SystemConstant.defaultCountry.localized()
    }
    
    var orderData: OrderProductModel? {
        didSet {
            if let temp = orderData?.qtyReturned {
                qty = temp
            }
        }
    }
    
    var orderDetailModel: OrderDetailModel? {
        didSet {
            setData()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func increaseQtyButton(_ sender: UIButton) {
        if let maxOrder = orderData?.qty {
            if qty < maxOrder {
                qty += 1
                itemQtyLabel.text = String(qty)
                orderData?.qtyReturned = qty
                decreaseButton.alpha = 1.0
                //                orderData?.isSelected = true
            }
            if qty == maxOrder {
                increaseButton.alpha = 0.1
            }
        }
    }
    
    @IBAction func decreaseQtyButton(_ sender: UIButton) {
        let minOrder = 1
        if qty > minOrder {
            qty -= 1
            orderData?.qtyReturned = qty
            itemQtyLabel.text = String(qty)
            increaseButton.alpha = 1.0
        }
        if qty == minOrder {
            decreaseButton.alpha = 0.1
        }
    }
    
    @IBAction func tapOnReturnCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            if let orderModel = orderData, let maxQty = orderData?.qty {
                orderModel.qtyReturned = orderModel.qtyReturned == 0 ? maxQty : orderModel.qtyReturned
            }
            orderData?.isSelected = true
        }
        if sender.isSelected == false {
            orderData?.isSelected = false
        }
    }
}


extension OrderReturnTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reason.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reason[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        orderData?.reason = reason[row]
        reasonPicker.text = reason[row]
        
        //        selectedButton.isSelected = true
        //        orderData?.isSelected = true
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: MainScreen.width, height: 50))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.text = reason[row]
        label.sizeToFit()
        return label
    }
}

extension OrderReturnTableViewCell {
    func setupCell(productModel: OrderProductModel) {
        if let itemName = productModel.name, let itemPrice = productModel.price, let itemSKU = productModel.sku, let maxQty = productModel.qty {
            productNameLabel.text = itemName
            skuLabel.text = ConstantString.sku.uppercased().localized() + " " + itemSKU
            priceLabel.attributedText = Utils().createPriceAttribueString(regularPrice: String(itemPrice), specialPrice: "")
            qty = productModel.qtyReturned == 0 ? maxQty : productModel.qtyReturned
            self.itemQuantityLabel.text = "\(maxQty) " + "item(s)".localized()
            itemQtyLabel.text = "\(qty)"
            
            if maxQty == 1 {
                increaseButton.alpha = 0.1
                decreaseButton.alpha = 0.1
            } else if productModel.qtyReturned < maxQty && productModel.qtyReturned != 0 {
                increaseButton.alpha = 1.0
                decreaseButton.alpha = productModel.qtyReturned == 1 ? 0.1 : 1.0
            } else {
                increaseButton.alpha = 0.1
                decreaseButton.alpha = 1.0
            }
        }
        
        guard let itemOptions = productModel.extensionAttribute else { return }
        if let imageURL = itemOptions.imageURL {
            setImage(imageURL: imageURL)
        }
        if let color = itemOptions.options?.filter({($0.label ?? "") == "Color"}).first?.value {
            productColorLabel.text = color
        }
        if let size = itemOptions.options?.filter({($0.label ?? "") == "Size"}).first?.value {
            productSizeLabel.text = size
        }
        selectedButton.isSelected = productModel.isSelected
        reasonPicker.text = productModel.reason
    }
    
    func setImage(imageURL: String) {
        if let urlString = (AppConfigurationModel.sharedInstance.productMediaUrl! + "\(imageURL)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString ) {
            let request = URLRequest(url: url)
            DispatchQueue.global(qos: .background).async {
                self.productImage.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                    DispatchQueue.main.async(execute: {
                        self.productImage.alpha = 0.0
                        self.productImage.image = image
                        UIView.animate(withDuration: 0.5, animations: {self.productImage.alpha = 1.0})
                    })
                }, failure: nil)
            }
        } else {
            productImage.image = Image.placeholder
        }
    }
    
    // Disable copy paste on password textField.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if reasonPicker.isFirstResponder {
            OperationQueue.main.addOperation({() -> Void in
                UIMenuController.shared.setMenuVisible(false, animated: false)
            })
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
