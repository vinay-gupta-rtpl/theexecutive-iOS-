//
//  Utils.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class Utils: NSObject {
    func createPriceAttribueString(regularPrice: String, specialPrice: String) -> NSAttributedString {
        var priceText = "IDR".localized() + " " + regularPrice.changeStringToINR()
        var attPrice = NSMutableAttributedString(string: priceText)
        
        if let regular = Double(regularPrice), let special = Double(specialPrice), regular.isEqual(to: special) || special.isEqual(to: 0.0) {
            return attPrice
        }
        
        if !specialPrice.isEmpty {
            priceText += " " + "IDR".localized() + " \(specialPrice.changeStringToINR())"
            
            attPrice = NSMutableAttributedString(string: priceText)
            if let priceRange = priceText.range(of: "IDR".localized() + " \(regularPrice.changeStringToINR())")?.nsRange {
                attPrice.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 12.0), range: priceRange)
                attPrice.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: priceRange)
                attPrice.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: priceRange)
            }
            
            if let priceRange = priceText.range(of: "IDR".localized() + " \(specialPrice.changeStringToINR())")?.nsRange {
                attPrice.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 15.0), range: priceRange)
                attPrice.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: priceRange)
            }
            return attPrice
        }
        return attPrice
    }
    
    func showAlert(title: String?, message: String?) {
        guard let alertTitle = title, let alertMessage = message else {
            return
        }
        let alertView = UIAlertController(title: alertTitle,
                                          message: alertMessage,
                                          preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: AlertButton.okay, style: .cancel, handler: nil)
        alertView.addAction(okButton)
        appDelegate.window?.rootViewController?.present(alertView, animated: true, completion: nil)
    }
}
