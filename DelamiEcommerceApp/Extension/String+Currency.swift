//
//  String+Currency.swift
//  DelamiEcommerceApp
//
//  Created by Kritika on 23/4/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import Foundation

extension String {
    func changeStringToINR() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "en_US")

        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        var priceString = ""
        if self != "" {
            priceString = currencyFormatter.string(from: NSNumber.init(value: Double(self)!))!
        }
        return priceString.replacingOccurrences(of: ",", with: ".") // according to the client requirement change , with decimal and work as same as decimal number system.
    }
}
