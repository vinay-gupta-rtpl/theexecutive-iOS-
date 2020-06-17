//  AppDelegate.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 09/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import UIKit
import Firebase
import UserNotifications
import GoogleSignIn
import FBSDKCoreKit
import ZDCChat
import Fabric
import Crashlytics

@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isVersionUpdateAvailable = false
    var userName: String?
    var userEmail: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        
        // request for app version and maintenance settings
        AppConfigurationModel.sharedInstance.requestForAppConfiguration()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        // checking that the app language is already selected or not.
        if UserDefaults.instance.getStoreCode() != nil {
              LanguageViewModel().requestForAppSupportedLanguages()
            let rootVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.rootViewController) as? DelamiTabBarController  // this is default root view controller of the app
            window?.rootViewController = rootVC
        } else {
            let selectLanguageVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.language) as? LanguageViewController
            let navigationController = UINavigationController(rootViewController: selectLanguageVC!)
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
        
        // changing status bar appearance
        UIApplication.shared.statusBarStyle = .default
//        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//        statusBar?.backgroundColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .black
        
        // Use Firebase library to configure APIs
//        FirebaseApp.configure()
        congiureFireBase()
        
        // Facebook SignIn using Firebase
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google SignIn and set Client ID
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        ZDCChat.initialize(withAccountKey: Zendesk.accountKey)
        
        // FABRIC CRASHTLTICS
        Fabric.with([Crashlytics.self])
        //            Crashlytics.sharedInstance().crash()
        
        // Integrate Push Notification
        // Register for device token
        registerForDeviceToken()
        
        // Check whether we have clicked the notification from notification center
        // When app was force killed
        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            print("Came via Notification Center with data \(remoteNotification)")
            DataStorage.instance.isLaunchedByNotificationCenter = true
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // show badge count 0 when enter in app.
        
        //Activate a Event Tracker For Facebook Analytics...
        AppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            let path: String = url.absoluteString
            if path.contains("fb") {
                // Facebook Handler
                let handled: Bool = ApplicationDelegate.shared.application(application, open: url, options: options)
                return handled
            } else {
                // Gmail Handeler
                return GIDSignIn.sharedInstance()?.handle(url) ?? false
            }
    }
    
    func congiureFireBase() {
        FirebaseApp.configure(options: FirebaseOptions.init(contentsOfFile: Bundle.main.path(forResource: "LiveGoogleServiceInfo", ofType: "plist")!)!)
        Messaging.messaging().delegate = self
    }
    // Push notification Messages
    /*  func congiureFireBase() {
     FirebaseApp.configure()
     Messaging.messaging().delegate = self
     
     } */
    
    func registerForDeviceToken() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        
        /*let deviceID = NSData(data: deviceToken)
        let deviceTokenString = "\(deviceID)"
            .trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            .replacingOccurrences(of: " ", with: "")
        print("deviceTokenString : \(deviceTokenString)")
        
        UserDefaults.instance.setDeviceToken(value: deviceTokenString)*/
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        //We have to save this to just chek that we have to ask permission...
        UserDefaults.instance.setDeviceToken(value: deviceTokenString)
        print("Device Token \(deviceTokenString)")
        
        Messaging.messaging().delegate = self
        //        self.setNotificationCategory() // set Notification category button for eg. Open/Cancel etc. when click on notification.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register with error: \(error)")
        //self.displayError(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //        self.parseUserInfoAndShowPushMessage(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // in case of open and default touch on notification. This method will only call when there were in completion handler .dismissAndForward action.
        self.parseUserInfoAndShowPushMessage(response.notification.request.content.userInfo)
        
        // API call for read status of notification
        if let notificationId = response.notification.request.content.userInfo["notification_id"] as? String {
            AppConfigurationModel.sharedInstance.updateReadStatusOfNotification(notificationId: notificationId)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM token is: \(fcmToken)")
        if UserDefaults.instance.getFCMRegistrationToken() != fcmToken {
            UserDefaults.instance.setFCMRegistrationToken(value: fcmToken)
        }
        
        // API call for Register a device [Guest]
        AppConfigurationModel.sharedInstance.registerGuestDevice()
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("didReceive")
        completionHandler()
    }
    
    func parseUserInfoAndShowPushMessage(_ userInfo: [AnyHashable: Any]) {
        if (userInfo["aps"] as? [String: AnyObject]) != nil {
            
            if let type = userInfo["type"] as? String {
                
                switch type {
                case NotificationType.category.rawValue:
                    moveToCategoryVC(userInfo: userInfo)
                    
                case NotificationType.product.rawValue:
                    moveToProductVC(userInfo: userInfo)
                    
                case NotificationType.order.rawValue:
                    moveToOrderDetailVC(userInfo: userInfo)
                    
                case NotificationType.abendentCart.rawValue:
                    moveToCartVC(userInfo: userInfo)
                    
                default: // default case for bank transfer and notification Listing
                    moveToNotificationListingVC(userInfo: userInfo)
                }
            }
        }
    }
    
    func setNotificationCategory() {
        let openAction = UNNotificationAction(identifier: "open", title: "Open", options: .authenticationRequired)
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Cancel", options: .destructive)
        let defaultCategory = UNNotificationCategory(identifier: "defaultCategory", actions: [openAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([defaultCategory])
    }
    
    func moveToCategoryVC(userInfo: [AnyHashable: Any]) {
        if let typeId = userInfo["typeId"] as? String {
            
            let catModal = CatalogViewModel()
            catModal.categoryId = Int(typeId)
            
            if let catalogController = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.catalog) as? CatalogViewController {
                catalogController.viewModel = catModal
                catalogController.screenType = ComingFromScreen.appDelegate.rawValue
                catalogController.navTitle = userInfo["redirect_title"] as? String ?? ""
                let navController = UINavigationController.init(rootViewController: catalogController)
                UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func moveToProductVC(userInfo: [AnyHashable: Any]) {
        if let skuID = userInfo["typeId"] as? String {
            
            let viewModal = ProductDetailViewModel()
            viewModal.getProductDetails(skuId: skuID, success: { (response) in
                
                if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController {
                    
                    viewController.productModel = response as? ProductModel
                    viewController.comingFrom = ComingFromScreen.appDelegate.rawValue
                    viewController.navTitle = userInfo["redirect_title"] as? String ?? ""
                    let navController = UINavigationController.init(rootViewController: viewController)
                    UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
                }
            }, failure: { (_) in
                
            })
        }
    }
    
    func moveToOrderDetailVC(userInfo: [AnyHashable: Any]) {
        guard UserDefaults.standard.getUserToken() != nil else { return }
        
        if let orderId = userInfo["typeId"] as? String {
            guard let orderDetailVC = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.orderDetail) as? OrderDetailViewController else { return }
            orderDetailVC.orderNo = orderId
            
            orderDetailVC.comingFrom = ComingFromScreen.appDelegate.rawValue
            orderDetailVC.navTitle = userInfo["redirect_title"] as? String ?? ""
            let navController = UINavigationController.init(rootViewController: orderDetailVC)
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }
    }
    
    func moveToNotificationListingVC(userInfo: [AnyHashable: Any]) {
        guard UserDefaults.standard.getUserToken() != nil else { return }
        
        if let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.notification) as? NotificationListingViewController {
            viewController.comingFrom = ComingFromScreen.appDelegate.rawValue
            let navController = UINavigationController.init(rootViewController: viewController)
            UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
        }
    }
    
    func moveToCartVC(userInfo: [AnyHashable: Any]) {
        guard UserDefaults.standard.getUserToken() != nil else { return }
        
        guard let viewController = StoryBoard.myCart.instantiateViewController(withIdentifier: SBIdentifier.shoppingBag) as? ShoppingBagViewController else { return }
        let navController = UINavigationController.init(rootViewController: viewController)
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIApplication {
    class func findTopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
