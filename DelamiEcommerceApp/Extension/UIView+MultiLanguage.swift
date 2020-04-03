//
//  UIView+MultiLanguage.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 26/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

extension UIView {
    func updateStringsForApplicationGlobalLanguage() {
        for view in self.subviews {
            if view.isKind(of: UILabel.self) {
                if let label = view as? UILabel {
                    if (label.text?.count ?? 0) > 0 && label.text != label.text?.localized() {
                        label.text = label.text?.localized()
                    }
                }
            } else if view.isKind(of: UIButton.self) {
                if let button = view as? UIButton {
                    if (button.titleLabel?.text?.count ?? 0) > 0 {
                        button.setTitle(button.titleLabel?.text?.localized(), for: UIControlState())
                    }
                }
            } else if view.isKind(of: UITextField.self) {
                if let textField = view as? UITextField {
                    if (textField.placeholder?.count ?? 0) > 0 {
                        textField.placeholder = textField.placeholder?.localized()
                    }
                }
            } else {
                view.updateStringsForApplicationGlobalLanguage()
            }
        }
    }
}
