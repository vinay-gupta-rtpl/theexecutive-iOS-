//
//  DelamiViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 09/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class DelamiViewController: UIViewController {
    var orientation: Orientation = UIDevice.current.orientation.isLandscape ? .landscape : .portrait
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove navigation bar bottom border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: FontUtility.mediumFontWithSize(size: 19.0)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.updateStringsForApplicationGlobalLanguage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        MainScreen.width = UIScreen.main.bounds.width
        MainScreen.height = UIScreen.main.bounds.height
    }
}

// App maintenance mode functionality
extension DelamiViewController {
    func notifyMaintenanceMode() {
        guard let maintenanceMessage = AppConfigurationModel.sharedInstance.maintenanceMessage else {
            return
        }
        
        let alertController = UIAlertController(title: title,
                                          message: maintenanceMessage,
                                          preferredStyle: .alert)
        
        let exitButton = UIAlertAction(title: AlertButton.exit.localized(), style: .default, handler: { (_) in
            exit(0)
        })
        
//        let visitSiteButton = UIAlertAction(title: "Visit Site", style: .default, handler: { (_) in
//            if let urlToOpen = URL(string: Configuration().environment.baseURL) {
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
//                } else {
//                    UIApplication.shared.openURL(urlToOpen)
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.present(alertController, animated: true, completion: nil)
//            }
//        })
        
        alertController.addAction(exitButton)
//        alertController.addAction(visitSiteButton)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension DelamiViewController {
    // MARK: - Show alert messages from here
    func showAlertWith(title: String?, message: String?, handler: ((_ action: UIAlertAction) -> Void)?) {
        if let title = title, let message = message {
            let alertView = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: AlertButton.okay.localized(), style: .cancel, handler: handler)
            alertView.addAction(okButton)
//            self.present(alertView, animated: true, completion: nil)
             UIApplication.findTopViewController()?.present(alertView, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTwoButton(title: String?, message: String?, okayHandler: @escaping((_ action: UIAlertAction) -> Void), cancelHandler: @escaping((_ action: UIAlertAction) -> Void)) {
        if let title = title, let message = message {
            let alertView = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: AlertButton.cancel.localized(), style: .default, handler: cancelHandler)
            let okButton = UIAlertAction(title: AlertButton.okay.localized(), style: .default, handler: okayHandler)
            alertView.addAction(cancelButton)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    // MARK: - Add navigation bar buttons from here
    
    // Back Button
    public func addBackBtn(imageName: UIImage) {
        let leftBarBtn = UIButton()
        leftBarBtn.setImage(imageName, for: .normal)
        leftBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBarBtn.setTitle("  ", for: .normal) // added string as title because according to mockups image should be bit left aligned while normally image set to center aligned on button.
        leftBarBtn.setTitleColor(.black, for: .normal)        
        leftBarBtn.addTarget(self, action: #selector(actionBackButton), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarBtn)
    }
    
    // Back Action
    @objc func actionBackButton() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Cross Button
    public func addCrossBtn(imageName: UIImage) {
        let leftBarBtn = UIButton()
        leftBarBtn.setImage(imageName, for: .normal)
        leftBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBarBtn.setTitleColor(.black, for: .normal)
        leftBarBtn.addTarget(self, action: #selector(actionCrossButton), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarBtn)
    }
    
    // Cross Action
    @objc func actionCrossButton() {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Shopping Bag Button
    public func addCartBtn(imageName: UIImage, cartCount: Int? = 0) {
        let rightBarBtn = UIButton()
        rightBarBtn.setBackgroundImage(imageName, for: .normal)
        rightBarBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        rightBarBtn.setTitleColor(UIColor.black, for: .normal)
        rightBarBtn.contentVerticalAlignment = .bottom
        rightBarBtn.addTarget(self, action: #selector(moveToShoppingBag), for: .touchUpInside)
        
        if let count = cartCount, count != 0, count < 100 {
            rightBarBtn.setTitle("\(count)", for: .normal)
            rightBarBtn.titleLabel?.font = FontUtility.regularFontWithSize(size: 13)
        }
        if let count = cartCount, count > 99 {
            rightBarBtn.setTitle(SystemConstant.CartCountMoreThanHundard, for: .normal)
            rightBarBtn.titleLabel?.font = FontUtility.regularFontWithSize(size: 11)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarBtn)
    }
    
    // Shopping Bag Button Action
    @objc func moveToShoppingBag() {
        guard let viewController = StoryBoard.myCart.instantiateViewController(withIdentifier: SBIdentifier.shoppingBag) as? ShoppingBagViewController else {
            return
        }
        let nav = UINavigationController.init(rootViewController: viewController)
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Update shopping bag count
    public func updateCartCount() {
        var userType: UserType = .guest
        if UserDefaults.standard.getUserToken() != nil {
            userType = .registeredUser
            addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"), cartCount: UserDefaults.standard.getUserCartCount() ?? 0)
        } else { // guest user
            addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"), cartCount: UserDefaults.standard.getGuestCartCount())
            
            guard UserDefaults.standard.getGuestCartToken() != nil else {
                return
            }
        }
        
        DelamiTabBarViewModel().requestForGetCartCount(user: userType, success: { [weak self] (cartCount) in
            self?.addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"), cartCount: cartCount)
            }, failure: { (_) in
        })
    }
}
