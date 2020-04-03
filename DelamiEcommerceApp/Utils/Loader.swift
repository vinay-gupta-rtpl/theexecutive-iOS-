//
//  Loader.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 23/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

public class Loader {
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    class var shared: Loader {
        struct Static {
            static let instance: Loader = Loader()
        }
        return Static.instance
    }

    public func showLoading() {
        guard UIApplication.shared.keyWindow?.subviews.filter({ $0.accessibilityIdentifier == "loader" }).first == nil else {
            return
        }
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.accessibilityIdentifier = "loader"
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.keyWindow?.addSubview(overlayView)
    }
    
    public func showLoadingOnView(view: UIView?) {
        guard let loaderView = view, loaderView.subviews.filter({ $0.accessibilityIdentifier == "loader" }).first == nil else {
            return
        }
        overlayView = UIView(frame: loaderView.bounds)
        overlayView.accessibilityIdentifier = "loader"
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        loaderView.addSubview(overlayView)
        loaderView.bringSubview(toFront: overlayView)
    }

    public func hideLoading() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
    public func hideLoadingOnView(view: UIView?) {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
        
        guard let loaderOverlay = view?.subviews.filter({ $0.accessibilityIdentifier == "loader" }).first else {
            return
        }
        loaderOverlay.removeFromSuperview()
    }
}
