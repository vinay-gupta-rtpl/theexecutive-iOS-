//
//  UITextField+Design.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import UIKit

extension UITextField: UIPickerViewDelegate {
    
    func setRightViewImage(image: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btnView.setImage(image, for: .normal)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        self.rightViewMode = .always
        self.rightView = btnView
        self.rightView?.isUserInteractionEnabled = false
    }
    
}
