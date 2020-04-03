//
//  ShoppingBagCheckoutCellTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol CheckoutCall: class {
    func applyPromoCode(promoCode: String)
    func deletePromoCode()
    func checkoutActionCalled()
}

class ShoppingBagCheckoutCell: UITableViewCell {
    @IBOutlet weak var productTotalStackView: UIStackView!
    @IBOutlet weak var productTotalValueLabel: UILabel!
    @IBOutlet weak var discountStackView: UIStackView!
    @IBOutlet weak var discountValueLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var promoCodeStackView: UIStackView!
    @IBOutlet weak var promoCodeTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    
    @IBOutlet weak var invalidPromoCodeStack: UIStackView!
    @IBOutlet weak var promoCodeRemoveButton: UIButton!
    @IBOutlet weak var promoNameLabel: UILabel!
    @IBOutlet weak var appliedPromoCodeStack: UIStackView!
    @IBOutlet weak var promoTextAndApplyStack: UIStackView!
    
    // MARK: - Delegate
    weak var checkoutCallDelegate: CheckoutCall?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyButton.layer.borderWidth = 0.5
        applyButton.layer.borderColor = UIColor.black.cgColor
        applyButton.layer.cornerRadius = 2.0
        
        productTotalStackView.isHidden = true
        discountStackView.isHidden = true
        totalLabel.isHidden = true
        totalValueLabel.isHidden = true
        
        promoNameLabel.layer.borderWidth = 0.5
        promoNameLabel.layer.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(viewModel: ShoppingCartViewModel) {
        if let subTotal = viewModel.cartTotals?.totals.filter({ $0.code == "subtotal" }).first?.value {
            let productsTotal = String(subTotal)
            productTotalStackView.isHidden = (viewModel.promoCode?.isEmpty ?? true)
            productTotalValueLabel.text = SystemConstant.defaultCurrencyCode.localized() + " " + productsTotal.changeStringToINR()
        }
        
        if let promoDiscount = viewModel.cartTotals?.totals.filter({ $0.code == "discount" }).first?.value {
            let discount = String(promoDiscount)
            discountStackView.isHidden = false
            discountValueLabel.text = SystemConstant.defaultCurrencyCode.localized() + " " + discount.changeStringToINR()
        }
        
        if let grandTotal = viewModel.cartTotals?.subtotalWithDiscount {
            let price = String(grandTotal)
            totalLabel.text = (viewModel.promoCode?.isEmpty ?? true) ? "Product Total".localized() : "Grand Total".localized()
            totalLabel.isHidden = false
            totalValueLabel.isHidden = false
            totalValueLabel.text = SystemConstant.defaultCurrencyCode.localized() + " " + price.changeStringToINR()
        }
        
        if let promoCode = viewModel.promoCode {
            if promoCode != "" {
                // show promo code stack
                self.promoCodeStackView.isHidden = false
                self.appliedPromoCodeStack.isHidden = false
                self.promoTextAndApplyStack.isHidden = true
                self.invalidPromoCodeStack.isHidden = true
                self.promoNameLabel.text = " " + promoCode + " "
                discountStackView.isHidden = false
                
            } else if viewModel.wrongPromoApplied {
                // show invalid promo code label
                self.promoCodeStackView.isHidden = false
                self.appliedPromoCodeStack.isHidden = true
                self.promoTextAndApplyStack.isHidden = false
                self.invalidPromoCodeStack.isHidden = false
                discountStackView.isHidden = true
                
            } else {
                // hide promo code parent stack in which invalid promo label and promo code stack both include.
                self.invalidPromoCodeStack.isHidden = true
                self.promoCodeStackView.isHidden = true
                self.appliedPromoCodeStack.isHidden = true
                self.promoTextAndApplyStack.isHidden = false
                discountStackView.isHidden = true
                
            }
        }
    }
    
    @IBAction func tapOnApplyPromoCode(_ sender: UIButton) {
        if promoCodeTextField.text != "" {
            checkoutCallDelegate?.applyPromoCode(promoCode: promoCodeTextField.text!)
            self.promoCodeTextField.text = ""
        }
    }
    
    @IBAction func tapOnCheckoutButton(_ sender: UIButton) {
        checkoutCallDelegate?.checkoutActionCalled()
    }
    
    @IBAction func deleteAppliedPromoCode(_ sender: Any) {
        checkoutCallDelegate?.deletePromoCode()
    }
}

extension ShoppingBagCheckoutCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
