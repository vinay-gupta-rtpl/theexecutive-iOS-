//
//  iTextfieldExtension.swift
//  iComponents
//
//  Created by Rahul Panchal on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

import Foundation
import UIKit

let kDefaultBottomBorderWidth: CGFloat = 0.5
let kDefaultBottomBorderColor = UIColor.darkGray
let kFloatingLabelHeight: CGFloat = 21.0
let kFloatingLabelAnimationDuration = 0.3
let kDefaultFloatingLabelTextColor = UIColor.gray
let kDefaultFloatingLabelPadding: CGFloat = 0.0

public extension UITextField {
    
    private struct AssociatedKey {
        static var floatingLabelColor    = "floatingLabelColor"
        static var floatingLabelXPadding = "floatingLabelXPadding"
        static var floatingLabelYPadding = "floatingLabelYPadding"
    }
    
    /**
     * Add color to placeholder text of the textfield.
     * Defaults is gray color
     */
    var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
    
    /**
     * Text color of the floating label upon presentation.
     * Defaults is gray color
     */
    var floatingLabelTextColor: UIColor? {
        get {
            guard (objc_getAssociatedObject(self, &AssociatedKey.floatingLabelColor) as? UIColor != nil) else {
                return kDefaultFloatingLabelTextColor
            }
            return objc_getAssociatedObject(self, &AssociatedKey.floatingLabelColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.floatingLabelColor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /**
     * Padding to be applied to the x coordinate of the floating label upon presentation.
     * Defaults to zero
     */
    var floatingLabelXPadding: CGFloat {
        get {
            guard (objc_getAssociatedObject(self, &AssociatedKey.floatingLabelXPadding) != nil) else {
                return kDefaultFloatingLabelPadding
            }
            return (objc_getAssociatedObject(self, &AssociatedKey.floatingLabelXPadding) as? CGFloat)!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.floatingLabelXPadding, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /**
     * Padding to be applied to the y coordinate of the floating label upon presentation.
     * Defaults to zero.
     */
    var floatingLabelYPadding: CGFloat {
        get {
            guard (objc_getAssociatedObject(self, &AssociatedKey.floatingLabelYPadding) != nil) else {
                return kDefaultFloatingLabelPadding
            }
            return (objc_getAssociatedObject(self, &AssociatedKey.floatingLabelYPadding) as? CGFloat)!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.floatingLabelYPadding, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /**
     *  Sets the textfield left padding
     *
     *  @param amount The value is used to add padding at the left side of the textfield.
     */
    func setLeftPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    /**
     *  Sets the textfield left padding
     *
     *  @param amount The value is used to add padding at the right side of the textfield.
     */
    func setRightPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    /**
     *  Adds a border to the bottom of the textfield
     *
     *  @param width The value is optional and used to apply thickness to border and default value is 0.5.
     *  @param borderColor The value is optional and used to apply color to border and default value is gray color.
     */
    func addBottomBorder(width: CGFloat? = 0.5, borderColor: UIColor? = .gray) {
        let border = CALayer()
        border.borderColor = borderColor!.cgColor
        border.frame = CGRect(x: 0.0, y: self.bounds.size.height - width!, width:  self.bounds.size.width, height: self.bounds.size.height)
        border.borderWidth = width!
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    /**
     *  Sets floating label to the textfield
     *
     */
    func setTextFieldWithFloatingLabel() {
        let floatingLabel: UILabel = UILabel()
        floatingLabel.text = self.placeholder
        floatingLabel.adjustsFontSizeToFitWidth = true
        floatingLabel.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! * 0.7)
        floatingLabel.textAlignment = .left
        floatingLabel.textColor = floatingLabelTextColor
        floatingLabel.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: kFloatingLabelHeight)
        floatingLabel.alpha = 0.0
        self.superview?.addSubview(floatingLabel)
        self.addTarget(self, action: #selector(hideShowFloatingLabel), for: UIControlEvents.editingChanged)
    }
    
    @objc internal func hideShowFloatingLabel() {
        let trimmedText = self.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        let isShowFloatingLabel = trimmedText == "" ? false : true
        for subview in (self.superview?.subviews)! {
            if subview.isKind(of: UILabel.self) {
                let label: UILabel = (subview as? UILabel)!
                if label.text == self.placeholder {
                    label.textColor = floatingLabelTextColor
                    UIView.animate(withDuration: kFloatingLabelAnimationDuration, delay: 0.0, options: [.beginFromCurrentState, isShowFloatingLabel ? .curveEaseOut : .curveEaseIn], animations: {
                        label.alpha = isShowFloatingLabel ? 1.0 : 0.0
                        let yOrigin = isShowFloatingLabel ? (self.frame.origin.y + self.floatingLabelYPadding) - 2 : (self.frame.origin.y + self.floatingLabelYPadding)
                        label.frame = CGRect(x: (self.frame.origin.x + self.floatingLabelXPadding), y: yOrigin, width: label.frame.size.width, height:
                            label.frame.size.height)
                    }, completion: nil)
                }
            }
        }
    }
    
}
