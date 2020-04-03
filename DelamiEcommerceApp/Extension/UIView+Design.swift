//
//  UIView+Design.swift
//  DelamiEcommerceApp
//
//  Created by Kritika on 23/4/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation
extension UIView {

    func showNoDataAvailable(noDataText: String, noDataTextColor: UIColor) {
        let lbl = UILabel(frame: CGRect(x: CGFloat(10), y: CGFloat(self.frame.size.height/2 - 40), width: CGFloat(self.frame.size.width - 20), height: CGFloat(80)))
        lbl.textColor = noDataTextColor
        lbl.numberOfLines = 3
        lbl.text = noDataText
        lbl.textAlignment = .center
        lbl.font = FontUtility.regularFontWithSize(size: 18)
        lbl.tag = 1000
        self.addSubview(lbl)
    }

    func setShadowOfView(shadowColor: UIColor, shadowOpacity: Float, radious: Float, shadowOffSet: CGSize) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffSet
        self.layer.shadowRadius = CGFloat(radious)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }

    func addBlurEffect(effectStyle: UIBlurEffectStyle? = .prominent) {
        let blurEffect = UIBlurEffect(style: effectStyle!)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }

}
