//
//  SizeAndQuantityView.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 09/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol AddToBagPopupCall: class {
    func doneButtonAction()
    func tapOnSizeGuideAction()
    func tapOnQtyButton(labelValue: UILabel, isIncrease: Bool)
    func removeView()
}

enum PopupType {
    case sizeAndQuantity
    case quantity
    case size
}

class SizeAndQuantityView: UIView {
    // MARK: - Variables
    var availableSizeCollectionView: UICollectionView!
    var quantityValueLabel: UILabel = UILabel()
    var priceLabel: UILabel?
    var popupType: PopupType? = .sizeAndQuantity

    weak var addToBagPopupDelegate: AddToBagPopupCall?
    
    func initializeView(viewController: UIViewController, type: PopupType, price: NSAttributedString) -> SizeAndQuantityView {
        popupType = type
        self.frame = CGRect(x: 0.0, y: 0.0, width: MainScreen.width, height: MainScreen.height)

        let addToBagViewHeight: CGFloat = type == .sizeAndQuantity ? 320.0 : (type == .size ? 250.0 : 180.0)
        let addToBagView = UIView(frame: CGRect(x: 0, y: self.frame.size.height - addToBagViewHeight, width: self.frame.size.width, height: addToBagViewHeight))
        let storeCode = UserDefaults.instance.getStoreCode() ?? ""
        addToBagView.addBlurEffect()

        var yOrigin: CGFloat = type == .quantity ? 10.0 : 25.0
        
        if type == .sizeAndQuantity || type == .size {
            let selectSizeLabel = createViewLabel(frame: CGRect(x: 16, y: yOrigin, width: 110, height: 40), title: ConstantString.selectSize.localized())
            addToBagView.addSubview(selectSizeLabel)
            yOrigin += selectSizeLabel.frame.height
            
            var availableSizeCollectionView: UICollectionView!
            let flowLayout = UICollectionViewFlowLayout()
            availableSizeCollectionView = UICollectionView(frame: CGRect(x: 22, y: yOrigin, width: MainScreen.width - 44, height: 80.0), collectionViewLayout: flowLayout)
            availableSizeCollectionView.showsHorizontalScrollIndicator = false
            yOrigin += availableSizeCollectionView.frame.height + 10.0
            
            let sizeGuideButtonWidth: CGFloat = storeCode == "ID" ? 160.0 : 105.0
            let sizeGuideButton = UIButton(frame: CGRect(x: self.frame.size.width - (sizeGuideButtonWidth + 16.0), y: selectSizeLabel.frame.origin.y, width: sizeGuideButtonWidth, height: 40.0))
            sizeGuideButton.setTitle(ConstantString.sizeGuide.localized(), for: .normal)
            sizeGuideButton.titleLabel?.font = FontUtility.mediumFontWithSize(size: 17.0)
            sizeGuideButton.titleLabel?.textAlignment = .right
            sizeGuideButton.setTitleColor(#colorLiteral(red: 0.1832801402, green: 0.1679286659, blue: 0.172621876, alpha: 1), for: .normal)
            sizeGuideButton.setImage(#imageLiteral(resourceName: "size_guide_icon"), for: .normal)
            sizeGuideButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            sizeGuideButton.addTarget(self, action: #selector(tapOnSizeGuide), for: .touchUpInside)
            addToBagView.addSubview(sizeGuideButton)
            
            availableSizeCollectionView.delegate = viewController as? UICollectionViewDelegate
            availableSizeCollectionView.dataSource = viewController as? UICollectionViewDataSource
            flowLayout.scrollDirection = .horizontal
            availableSizeCollectionView.isPagingEnabled = true
            availableSizeCollectionView.tag = 3
            availableSizeCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.ProductDetail.sizeCollection)
            availableSizeCollectionView.backgroundColor = .clear
            addToBagView.addSubview(availableSizeCollectionView)
        }
        
        // ---------------
        
        if type == .sizeAndQuantity || type == .quantity {
            let selectQunatityView = UIView(frame: CGRect(x: 0.0, y: yOrigin, width: 300.0, height: 150.0))
            
            let selectQuantityLabel = createViewLabel(frame: CGRect(x: 16.0, y: 5.0, width: 300.0, height: 40), title: ConstantString.selectQuantity.localized())
            selectQunatityView.addSubview(selectQuantityLabel)
            
            let quantityDecreaseButton = createQuantityButton(frame: CGRect(x: 20, y: 40, width: 25, height: 40), image: #imageLiteral(resourceName: "decrease_icon"), tag: 1)
            selectQunatityView.addSubview(quantityDecreaseButton)
            
            self.quantityValueLabel = createViewLabel(frame: CGRect(x: 48, y: quantityDecreaseButton.frame.origin.y, width: 50, height: quantityDecreaseButton.frame.height), title: "1", textAlignment: .center)
            self.quantityValueLabel.font = FontUtility.regularFontWithSize(size: 17.0)
            selectQunatityView.addSubview( self.quantityValueLabel)
            
            let quantityIncreaseButton = createQuantityButton(frame: CGRect(x: 100, y: quantityDecreaseButton.frame.origin.y, width: 25, height: quantityDecreaseButton.frame.height), image: #imageLiteral(resourceName: "increase_icon"), tag: 2)
            selectQunatityView.addSubview(quantityIncreaseButton)
            
            addToBagView.addSubview(selectQunatityView)
            yOrigin += selectQunatityView.frame.height
        }
        // ---------------

        let bottomView = UIView(frame: CGRect(x: 0.0, y: (addToBagViewHeight - 80.0), width: self.frame.size.width, height: 80.0))
        bottomView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9009132923)
        
//        let doneButton = UIButton(frame: CGRect(x: 20, y: 20.0, width: storeCode == "ID" ? 190.0 : 120.0, height: 40.0))
         let doneButton = UIButton(frame: CGRect(x: 20, y: 20.0, width: 120.0, height: 40.0))
        doneButton.backgroundColor = .clear
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        doneButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        doneButton.setTitle(type == .size ? ButtonTitles.addToWishlist.uppercased().localized() : ButtonTitles.addToBag.uppercased().localized(), for: .normal)
        doneButton.titleLabel?.font = FontUtility.regularFontWithSize(size: 15.0)
        doneButton.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        doneButton.layer.cornerRadius = 5.0
        bottomView.addSubview(doneButton)

        priceLabel = createViewLabel(frame: CGRect(x: doneButton.frame.maxX + 10.0, y: 18.0, width: self.frame.width - (doneButton.frame.maxX + 18.0), height: 44.0), title: "", textAlignment: .right)
        priceLabel?.adjustsFontSizeToFitWidth = true
        priceLabel?.font = FontUtility.regularFontWithSize(size: 16.0)
        priceLabel?.attributedText = price
        priceLabel?.numberOfLines = 0
        priceLabel?.lineBreakMode = .byWordWrapping
        bottomView.addSubview(priceLabel!)

        addToBagView.addSubview(bottomView)
        self.addSubview(addToBagView)
        return self
    }

    func createViewLabel(frame: CGRect, title: String, textAlignment: NSTextAlignment? = .left) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textAlignment = textAlignment!
        label.font = FontUtility.mediumFontWithSize(size: 17.0)
        return label
    }

    func createQuantityButton(frame: CGRect, image: UIImage, tag: Int) -> UIButton {
        let quantityIncreaseButton = UIButton(frame: frame)
        quantityIncreaseButton.tag = tag
        quantityIncreaseButton.imageView?.contentMode = .scaleAspectFit
        quantityIncreaseButton.setImage(image, for: .normal)
        quantityIncreaseButton.addTarget(self, action: #selector(quantityChange), for: .touchUpInside)
        return quantityIncreaseButton
    }

    @objc func quantityChange(sender: UIButton) {
        switch sender.tag {
        case 1: // Decrease Value by 1
           self.addToBagPopupDelegate?.tapOnQtyButton(labelValue: quantityValueLabel, isIncrease: false)
        case 2: // Increase Value by 1
          self.addToBagPopupDelegate?.tapOnQtyButton(labelValue: quantityValueLabel, isIncrease: true)
        default:
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let addToBagViewHeight: CGFloat = popupType == .sizeAndQuantity ? 320.0 : (popupType == .size ? 250.0 : 180.0)
        if let touchLocation = touches.first?.location(in: appDelegate.window).y, touchLocation < MainScreen.height - CGFloat(addToBagViewHeight) {
            self.addToBagPopupDelegate?.removeView()
        }
    }
    
    @objc func tapOnSizeGuide() {
        self.addToBagPopupDelegate?.tapOnSizeGuideAction()
    }
    
    @objc func doneButtonAction() {
        self.addToBagPopupDelegate?.doneButtonAction()
    }
}
