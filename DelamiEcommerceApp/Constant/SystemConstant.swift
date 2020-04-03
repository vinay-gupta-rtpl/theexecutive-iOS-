//
//  SystemConstant.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 06/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

struct SystemConstant {
    static let keyboardHeight: CGFloat = 255.0
    static let deviceType: String = "iOS"
    static let tabBarHeight: CGFloat = 49.0
    static let defaultCountry = "Indonesia"
    static let defaultCurrencyCode = "IDR".localized()
    static let defaultMobileCode = "+62"
    static let textFieldBottomViewHeght = 0.5
    static let defaultAddressId: Int64 = 0 // Default address when add a new shipping address in my account
    static let deviceToken: String = "6fc6e5010503cb5ce08c5d2f9b95g973f47e3bc116e07ae3d269da01547b1f3c"
    static let dateFormatterPattern = "dd-MM-YYYY"
    static let datePatternPresentingWay = "dd/MM/YYYY"
    static let defaultBankRecipient = "BCA – 494 3013 775"
    static let CartCountMoreThanHundard = "99+"
    static let newLine = "\n"
    static let plus = "+"
}

struct MainScreen {
    static var size = UIScreen.main.bounds
    static var width = size.width
    static var height = size.height
}

enum Orientation {
    case landscape
    case portrait
}

struct ThemeColor {
    static let black = #colorLiteral(red: 0.137254902, green: 0.1254901961, blue: 0.1294117647, alpha: 1)
    static let gray = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
}

enum ReturnReason: String {
//    case badQuality = "Bad Quality"
//    case notAccordance = "Not Accordance"
//    case other = "Other"
    
    case productNotFit = "Product does not fit"
    case incorrectProduct = "Incorrect product received"
    case notMatchDescription = "Product does not match description on website"
    case notMeetExpectation = "Product does not meet customer's expectations"
    case qualityIssue = "Quality issue"
}
