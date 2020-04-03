//
//  ZoomInOut.swift
//  imReporter
//
//  Created by Kritika Middha on 17/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

import UIKit
/**
 ZoomInOut class is for dispaly full view of image and zoom it.
 */
class ZoomInOut {
    /**
        shared instance of ZoomInOut class.
     */
    static let sharedInstance = ZoomInOut()
    
    /**
        image view to display image.
     */
    var zoomImageView = ZoomImageView()
}

extension UIView {
    
    /**
     Setup layout on device orientation change.
     
     */
    func layoutViewOnOrientationChange() {
        self.frame = UIScreen.main.bounds
        ZoomInOut.sharedInstance.zoomImageView.frame = CGRect(x: 0, y: 70.0, width: self.frame.width, height: self.frame.height - 70)
    }
    
    /**
         Setup view for Zoom In/Out and load that view on window.
    
         - parameter image: The image which will Zoom In/Out.
    */
    public func funcZoomInOut(image: UIImage, crossImage: UIImage) {
        // set up view
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.white
        
        ZoomInOut.sharedInstance.zoomImageView = ZoomImageView(frame: CGRect(x: 0, y: 70.0, width: self.frame.width, height: self.frame.height - 70))
        ZoomInOut.sharedInstance.zoomImageView.image = image
        ZoomInOut.sharedInstance.zoomImageView.zoomMode = .fit
        self.addSubview(ZoomInOut.sharedInstance.zoomImageView)
        
        // Create Close button on scroll
        let closeButton = UIButton()
//        closeButton.frame = CGRect(x: 10, y: self.frame.height == 812 ? 40.0 : 30.0, width: 30, height: 30)
         closeButton.frame = CGRect(x: 10, y: hasTopNotch() ? 40.0 : 30.0, width: 30, height: 30)
        closeButton.setImage(crossImage, for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.titleLabel?.textAlignment = .center
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        closeButton.titleLabel?.textColor = UIColor.black
        closeButton.addTarget(self, action: #selector(removeZoomViewFromWindow), for: .touchUpInside)
        self.addSubview(closeButton)
        
        // Add view to application window
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    /**
     Remove the loaded  Zoom In/Out view from window.
     */
    @objc func removeZoomViewFromWindow() {
        self.removeFromSuperview()
    }
    
    /*
     UI changes according to the notch.
     */
    func hasTopNotch() -> Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
