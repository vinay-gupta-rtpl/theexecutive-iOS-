//
//  KACircleCropViewController.swift
//  Circle Crop View Controller
//
//  Created by Keke Arif on 29/02/2016.
//  Copyright © 2016 Keke Arif. All rights reserved.
//

import UIKit

public protocol KACircleCropViewControllerDelegate {
    
    func circleCropDidCancel()
    func circleCropDidCropImage(_ image: UIImage)
    
}

public class KACircleCropViewController: UIViewController, UIScrollViewDelegate {
    
    public var delegate: KACircleCropViewControllerDelegate?
    
    var width: CGFloat? = 250
    var height: CGFloat? = 250
    var image: UIImage
    var scrollView = KACircleCropScrollView()
    var cutterView = KACircleCropCutterView()
    let imageView = UIImageView()
    let screen = UIScreen.main.bounds.size
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
    let okButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let backButton = UIButton()
    public var isOvalCrop = true
    
   public init(withImage image: UIImage, cropSize: CGSize = CGSize(width: 250, height: 250)) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        if !(cropSize.width.isEqual(to: 0)) && !(cropSize.height.isEqual(to: 0)) {
            
            setCropRatio(width: cropSize.width, height: cropSize.height)
        } else {
            self.width = 250
            self.height = 250
        }
//        if (cropSize.width.isEqual(to: 0)) || (cropSize.height.isEqual(to: 0)) {
//            
//            self.width = 250
//            self.height = 250
//        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: View management
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scrollView = KACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: self.width!, height: self.height!))
        cutterView = KACircleCropCutterView()
        cutterView.isOval = self.isOvalCrop
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        scrollView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        cutterView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size 
        var scaleWidth = CGFloat()
        
        scaleWidth = image.size.width < image.size.height ? scrollView.frame.size.width / scrollView.contentSize.width : scrollView.frame.size.height / scrollView.contentSize.height
        
//        if image.size.width < image.size.height {
//            scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
//        } else {
//            scaleWidth = scrollView.frame.size.height / scrollView.contentSize.height
//        }
        
        scrollView.minimumZoomScale = scaleWidth
        
        if imageView.frame.size.width < scrollView.frame.size.width {
            print("We have the case where the frame is too small")
            scrollView.maximumZoomScale = scaleWidth * 2
        } else {
            scrollView.maximumZoomScale = 1.0
        }
        
        scrollView.zoomScale = image.size.width == image.size.height ? scaleWidth * 2 : scaleWidth 
        if image.size.width == image.size.height {
            if imageView.frame.size.height > UIScreen.main.bounds.width {
                scrollView.zoomScale = scaleWidth
            } else {
                scrollView.zoomScale = scaleWidth * 2
            }
//                scrollView.zoomScale = scaleWidth * 2
//            } else {
//
//                scrollView.zoomScale = scaleWidth
        }
        if self.height! > imageView.frame.size.height {
            self.height = imageView.frame.size.height
            scrollView.frame = CGRect(x: 0, y: 0, width: self.width!, height: self.height!)
            cutterView.height = imageView.frame.size.height
            cutterView.width = self.width
            
        } else if self.width! > imageView.frame.size.width {
            self.width = imageView.frame.size.width
            scrollView.frame = CGRect(x: 0, y: 0, width: self.width!, height: self.height!)
            cutterView.height = self.height
            cutterView.width = imageView.frame.size.width
            
        } else {
            cutterView.width = self.width
            cutterView.height = self.height
        }
        if image.size.width < image.size.height || image.size.width == image.size.height {
            
            //Center vertically
            scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        } else {
            //Center Horizontally
                scrollView.contentOffset = CGPoint(x: (scrollView.contentSize.width - scrollView.frame.size.width)/2, y: 0)
            
        }
        
        //Add in the black view. Note we make a square with some extra space +100 pts to fully cover the photo when rotated
        cutterView.frame = view.frame
        cutterView.frame.size.height += 100
        cutterView.frame.size.width = cutterView.frame.size.height
        
        //Add the label and buttons
        label.text = "Move and Scale"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = label.font.withSize(17)
        
        okButton.setTitle("Choose", for: UIControlState())
        okButton.setTitleColor(UIColor.white, for: UIControlState())
        okButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        okButton.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)
        
        backButton.frame = CGRect(x: 10, y: 300, width: 100, height: 30)
        backButton.setTitle("Cancel", for: UIControlState())
        backButton.setTitleColor(UIColor.white, for: UIControlState())
        backButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        setLabelAndButtonFrames()
        
        view.addSubview(scrollView)
        view.addSubview(cutterView)
        cutterView.addSubview(label)
        cutterView.addSubview(okButton)
        cutterView.addSubview(backButton)
        scrollView.bounces = false
        
    }
    
    func setLabelAndButtonFrames() {
        
        scrollView.center = view.center
        cutterView.center = view.center
        
        label.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - label.frame.size.width/2, y: cutterView.frame.size.height/2 - view.frame.size.height/2 + 50)
        
        let xValue = cutterView.frame.size.width/2 + view.frame.size.width/2 - okButton.frame.size.width - 12
        let yValue = cutterView.frame.size.height/2 - view.frame.size.height/2 + (screen.height - 50)
        
        okButton.frame.origin = CGPoint(x: xValue, y: yValue)
        
        backButton.frame.origin = CGPoint(x: cutterView.frame.size.width/2 - view.frame.size.width/2 + 3, y: cutterView.frame.size.height/2 - view.frame.size.height/2 + (screen.height - 50))
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            self.setLabelAndButtonFrames()
            
            }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Button taps
    
    @objc func didTapOk() {

        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)

        let offset = scrollView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.width!, height: self.height!), false, 0)
        var circlePath = UIBezierPath()
        if isOvalCrop {
            
            circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width!, height: self.height!))
        } else {
            circlePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.width!, height: self.height!))
        }
        circlePath.addClip()
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let imageData = UIImagePNGRepresentation(finalImage!) {
            if let pngImage = UIImage(data: imageData) {
                delegate?.circleCropDidCropImage(pngImage)
            } else {
                delegate?.circleCropDidCancel()
            }
        } else {
            delegate?.circleCropDidCancel()
        }
        
    }
    
    @objc func didTapBack() {
        
        delegate?.circleCropDidCancel()
        
    }
    
    // MARK: Crop Methods
    
    func setCropRatio(width: CGFloat, height: CGFloat) {
        if width > height {
            var maxWidth = UIScreen.main.bounds.size.width - 20
            var maxHeight = CGFloat()
            maxHeight = (height/width) * maxWidth
            if maxHeight > UIScreen.main.bounds.size.height - 20 {
                let wid = maxWidth
                let hei = maxHeight
                maxHeight = UIScreen.main.bounds.size.height - 20
                 maxWidth = (hei/wid) * maxHeight
            }
            self.width = maxWidth
            self.height = maxHeight
        } else if width < height {
            if width < UIScreen.main.bounds.size.width - 20 {
                self.width = width
                self.height = height
                
            } else {
                
                var maxHeight = UIScreen.main.bounds.size.height - 20
                var maxWidth = CGFloat()
                maxWidth = (width/height) * maxHeight
                if maxWidth > UIScreen.main.bounds.size.width - 20 {
                    let wid = maxWidth
                    let hei = maxHeight
                    maxWidth = UIScreen.main.bounds.size.width - 20
                    maxHeight = (hei/wid) * maxWidth
                }
                self.width = maxWidth
                self.height = maxHeight
            }
        } else if width == height {
            self.width = width > UIScreen.main.bounds.size.width - 20 ? UIScreen.main.bounds.size.width - 20 : width
//            self.height = height > UIScreen.main.bounds.size.height - 20 ? UIScreen.main.bounds.size.height - 20 : height
            self.height = height > UIScreen.main.bounds.size.width - 20 ? UIScreen.main.bounds.size.width - 20 : height

        }
    }

}
