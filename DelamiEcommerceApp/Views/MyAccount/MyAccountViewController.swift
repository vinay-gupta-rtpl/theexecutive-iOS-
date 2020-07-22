//  MyAccountViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 22/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth


class MyAccountViewController: UITableViewController {
    @IBOutlet var myAccountTableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var unreadNotificationLabel: UILabel!
    
    var userModel: UserModel?
    var viewModelMyAccout = MyAccountViewModel()
    var informationModel: MyInformationModel?
    var notificationModel: [NotificationModel]?
    
    // MARK: - API Call
    func requestForGetMyInformation() {
        self.view.endEditing(true)
        viewModelMyAccout.requestForMyInfo(success: { [weak self] (response) in
            if let data = response as? MyInformationModel {
                self?.informationModel = data
            } else {
               self?.informationModel = nil
            }
            }, failure: { [weak self] _ in
                self?.informationModel = nil
        })
    }
    
    func getBankTransferMethods(type: BankTransfer) {
        BankTransferModel().getTransferMethod(forType: type, success: { (_) in
        }, failure: { (_) in
        })
    }
    
    func requestForUnreadNotificationCount() {
        viewModelMyAccout.requestForUnreadNotification(success: { [weak self] (response) in
            if let unreadNotificationCount = response {
                if unreadNotificationCount > 0 {
                    self?.unreadNotificationLabel.isHidden = false
                    if unreadNotificationCount < 100 {
                        self?.unreadNotificationLabel.text = "\(unreadNotificationCount)"
                    } else {
                        self?.unreadNotificationLabel.text = SystemConstant.CartCountMoreThanHundard
                    }
                } else {
                    self?.unreadNotificationLabel.isHidden = true
                }
            }
        }, failure: { _ in
        })
    }
    
    func actionLogout() {
        UserModel().logoutPerform(success: { (_) in
            // logout action perform
            self.clearCurrentUserData()
            GIDSignIn.sharedInstance()?.disconnect()
            
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
            center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
            
            self.moveToHome()
        }, failure: { (_) in
        })
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        
        // API for Bank Transfer Methods and Recipients.
        if DataStorage.instance.bankRecipient == nil {
            self.getBankTransferMethods(type: .recipients)
        }
        if DataStorage.instance.bankTransferMethod == nil {
            self.getBankTransferMethods(type: .transferMethod)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        requestForUnreadNotificationCount()
        self.setupNavigation()
        requestForGetMyInformation()
    }
    
    func viewSetUp() {
        self.unreadNotificationLabel.layer.cornerRadius = self.unreadNotificationLabel.frame.width/2
        self.unreadNotificationLabel.layer.masksToBounds = true
        
        // version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version: \(version)"
        }
    }
    
    func setupNavigation() {
        if let navigationBar = self.navigationController?.navigationBar {
            let containerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height))
            // remove navigation bar bottom border
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            
            let myAccountLabelFrame = CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: 28)
            let idLabelFrame = CGRect(x: 0, y: 29, width: navigationBar.frame.width, height: 15)
            
            let myAccountLabel = UILabel(frame: myAccountLabelFrame)
            myAccountLabel.text = NavigationTitle.myAddress.localized()
            myAccountLabel.font = FontUtility.mediumFontWithSize(size: 15.0)
            myAccountLabel.textAlignment = .center
            
            let idLabel = UILabel(frame: idLabelFrame)
            idLabel.text = userModel?.emailId
            if let userEmail = UserDefaults.standard.getUserEmail() {
                idLabel.text = userEmail
            }
            idLabel.font = FontUtility.regularFontWithSize(size: 12.0)
            idLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            idLabel.textAlignment = .center
            
            containerLabel.addSubview(myAccountLabel)
            containerLabel.addSubview(idLabel)
            
            self.navigationItem.titleView = containerLabel
        }
    }
    
    // MARK: - Logout Button Action
    @IBAction func tapOnLogout(_ sender: Any) {
        self.showAlertWith(title: AlertTitle.none, message: AlertMessage.logoutConfirm.localized(), okayHandler: { [weak self] _ in
            // Logout API perform
            self?.actionLogout()
            }, cancelHandler: { _ in
                
        })
    }
    
    func clearCurrentUserData() {
        appDelegate.userName = nil
        appDelegate.userEmail = nil
        
        DataStorage.instance.userAddressModel = nil
        DataStorage.instance.bankTransferMethod = nil
        DataStorage.instance.bankRecipient = nil
        
        UserDefaults().clearUserDefaultData()
        LoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
    }
    
    func moveToHome() {
        if let tabbar = appDelegate.window?.rootViewController as? UITabBarController {
            tabbar.selectedIndex = 0
        }
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Table view delegate protocol
extension MyAccountViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case MyAccountCellType.myInformation.rawValue:
            guard let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.myInformation) as? MyInformationViewController else {
                return
            }
            viewController.informationModel = self.informationModel
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.myOrders.rawValue:
            guard let viewController = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.myOrder) as? MyOrderViewController else {
                return
            }
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.shippingAddress.rawValue:
            guard let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.addressBook) as? AddressBookViewController else {
                return
            }
            viewController.informationModel = self.informationModel
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.notification.rawValue:
            guard let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.notification) as? NotificationListingViewController else {
                return
            }
            viewController.notificationModel = self.notificationModel
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.subscribeToNewsletter.rawValue:
            guard let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.newsLetter) as? NewsLetterViewController else {
                return
            }
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.selectLanguage.rawValue:
            guard let selectLanguageVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.language) as? LanguageViewController else {
                return
            }
            selectLanguageVC.comingFromScreen = ComingFromScreen.myAccount.rawValue
            self.navigationController?.pushViewController(selectLanguageVC, animated: true)
            
        case MyAccountCellType.bankTransfer.rawValue:
            guard let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.bankTransfer) as? BankTransferViewController else {
                return
            }
            self.navigationController?.pushViewController(viewController, animated: true)
            
        case MyAccountCellType.changePassword.rawValue:
            guard let changePasswordVC = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.changePassword) as?  ChangePasswordViewController else {
                return
            }
            self.navigationController?.pushViewController(changePasswordVC, animated: true)
            
        case MyAccountCellType.buyingGuide.rawValue:
            if let redirectionUrl = AppConfigurationModel.sharedInstance.buyingGuideUrl {
                let buyGuide: [String: Any] = [API.FacebookEventDicKeys.userEmail.rawValue: informationModel?.email ?? ""]
                AppEvents.logEvent(.init(FacebookEvents.buyingGuide.rawValue), parameters: buyGuide)
                openSafariwithUrl(url: redirectionUrl, title: NavigationTitle.buyingGuide.localized())
            }
            
        case MyAccountCellType.contactUs.rawValue:
            if let redirectionUrl = AppConfigurationModel.sharedInstance.contactUsUrl {
                let contactUS: [String: Any] = [API.FacebookEventDicKeys.userEmail.rawValue: informationModel?.email ?? ""]
//                AppEvents.logEvent(.init(FacebookEvents.contactUs.rawValue), parameters: contactUS)
                AppEvents.logEvent(.contact, parameters: contactUS)
                openSafariwithUrl(url: redirectionUrl, title: NavigationTitle.contactUs.localized())
            }
                
        case MyAccountCellType.setting.rawValue:
            guard let settingVC = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.setting) as?  SettingViewController else {
                return
            }
            self.navigationController?.pushViewController(settingVC, animated: true)
            
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
    
    func showAlertWith(title: String?, message: String?, okayHandler: @escaping((_ action: UIAlertAction) -> Void), cancelHandler: @escaping((_ action: UIAlertAction) -> Void)) {
        if let title = title, let message = message {
            let alertView = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)
            let okButton = UIAlertAction(title: AlertButton.okay.localized(), style: .default, handler: okayHandler)
            let cancelButton = UIAlertAction(title: AlertButton.cancel.localized(), style: .default, handler: cancelHandler)
            alertView.addAction(cancelButton)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
        }
    }
}

extension MyAccountViewController {
    func openSafariwithUrl(url: String, title: String?) {
        guard let linkURL = NSURL(string: url) as URL? else {
            return
        }
        
        if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
            webController.url = linkURL
            webController.navigationTitle = title
            let navigationController = UINavigationController(rootViewController: webController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
}
