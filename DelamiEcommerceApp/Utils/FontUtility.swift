//
//  FontUtility.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 22/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class FontUtility: UIFont {
    class func regularFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Open Sans", size: size)!
    }
    
    class func mediumFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: size)!
    }
    
    class func boldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size)!
    }
}
