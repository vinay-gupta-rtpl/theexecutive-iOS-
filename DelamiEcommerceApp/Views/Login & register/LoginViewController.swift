//
//  LoginViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 23/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: DelamiViewController {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var facebookSignUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var containerChildView: UIView!
    @IBOutlet weak var childViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var createAnAccountButton: UIButton!
    @IBOutlet weak var emailTextField: BindingTextfield! {
        didSet {
            self.emailTextField.bind { self.viewModelLogin.emailID = $0 }
        }
    }
    
    @IBOutlet weak var passwordTextField: BindingTextfield! {
        didSet {
            self.passwordTextField.bind { self.viewModelLogin.password = $0 }
        }
    }
    
    // MARK: - Variables
    var viewModelLogin = LoginViewModel()
    var loggedInUserInfo: NSDictionary = [:]
    
    // MARK: - API Call
    func requestForLogin() {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelLogin.requestForCustomerLogin(success: { [weak self] (_) in
            Loader.shared.hideLoading()
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                self?.viewModelLogin.mergeGuestCartToUser(guestCartId: guestCartToken, success: { _ in
                }, failure: { _ in
                })
            }
            self?.setUserData()
        }, failure: { [weak self] (error) in
            Loader.shared.hideLoading()
            
            if let statusCode = error?.code, statusCode == 401 {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Invalid.loginCredential.localized(), handler: { _ in
                })
            } else {
                if let errorMsg = error?.userInfo["message"] {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                } else {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                    })
                }
            }
        })
    }
    
    func requestForSocialLogin(email: String, token: String, loginType: String) {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelLogin.requestForSocialLogin(email: email, token: token, loginType: loginType, success: { [weak self] in
            Loader.shared.hideLoading()
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                self?.viewModelLogin.mergeGuestCartToUser(guestCartId: guestCartToken, success: { _ in
                }, failure: { _ in
                })
            }
            self?.setUserData()
        }, failure: { (error) in
            Loader.shared.hideLoading()
            GIDSignIn.sharedInstance()?.disconnect()
            // not logged in successfully.
            if let msgStr = error.userInfo["message"] as? String {
                self.showAlertWith(title: AlertTitle.error.localized(), message: msgStr, handler: { _ in })
            }
            print(error)
        })
    }
    
    func requestIsEmailAvailable(email: String, token: String, type: String) {
        self.view.endEditing(true)
        viewModelLogin.requestForIsEmailAvailable(email: email, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if response { // First time login then move to register ViewController
                self?.moveToRegisterVC(token: token, type: type)
            } else { //API call to Social Login
                self?.requestForSocialLogin(email: email, token: token, loginType: type)
            }
        }, failure: { (error) in
            Loader.shared.hideLoading()
            // not logged in successfully.
            print(error)
        })
    }
    
    func requestForCreateCart() {
        DelamiTabBarViewModel().requestForGetCartToken(success: { [weak self] (_) in
            // fetching user account details
            MyAccountViewModel().requestForMyInfo(success: { (_) in
            }, failure: { (_) in
            })
            self?.goToDashboard()
        }, failure: { [weak self] (_) in
            self?.goToDashboard()
        })
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        // set the UI delegate of the GIDSignIn
        //GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance()?.disconnect()

        // facebookSignUpButton.delegate = (self as? FBSDKLoginButtonDelegate)!
        if AccessToken.current != nil {
            // User is logged in, do work such as go to next view controller.
        } else {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup navigation bar Items
        addCrossBtn(imageName: Image.cross)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 44))
        imageView.image = Image.homeLogo
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
    }
    
    func initializeView() {
        // tap gesture on view
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionDoneButton))
        view.addGestureRecognizer(tap)
        
//        if MainScreen.height == 812.0 {
        if hasTopNotch() {
            childViewHeightConstraint.constant -= 34.0
        }
    }
    
    func removeGuestData() {
         UserDefaults().clearGuestDefaultData()
    }
    
    // UI according to Notch
    func hasTopNotch() -> Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    // MARK: - Button Actions
    @IBAction func tapOnLogin(_ sender: Any) {
        if viewModelLogin.performValidation() {
            // Call API
            requestForLogin()
        } else {
            self.showAlertWith(title: AlertTitle.error, message: viewModelLogin.rule.message, handler: { _ in
            })
        }
    }
    
    @IBAction func forgotButtonAction(_ sender: Any) {
        let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.forgotPassword)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        guard let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.registerProfile) as? RegisterViewController else {
            return
        }
        viewController.viewModelRegister = RegisterViewModal()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Selector Actions
    @objc func actionDoneButton() {
        self.view.endEditing(true)
    }
    
    @IBAction func googleSignInAction(_ sender: Any) {
        Loader.shared.showLoading()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookSignInAction(_ sender: Any) {

        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email", "user_birthday"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                fbLoginManager.logOut()
                return
            }

            GraphRequest.init(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, friends, gender"]).start {(_, result, _) -> Void in
                if let resultDictionary: NSDictionary = result as? NSDictionary {
                    print(resultDictionary)
                    self.loggedInUserInfo = resultDictionary
                }
            }

            if (result?.isCancelled)! {
                return fbLoginManager.logOut()
            }

            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (_, error) in
                if let error = error {
                    print("Error is: \(error.localizedDescription)")
                    self.showAlertWith(title: AlertTitle.error.localized(), message: "Something went wrong please try again", handler: { _ in })
                    return
                }
                if self.loggedInUserInfo.count > 0 {
                    if let email = (self.loggedInUserInfo.value(forKey: "email") as? String) {
                        self.requestIsEmailAvailable(email: email, token: accessToken.tokenString, type: "facebook")
                    }
                } else {
                    self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                    })
                }
            })
        }
    }

    // MARK: - View methods
    func moveToRegisterVC(token: String, type: String) {
        let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.registerProfile) as? RegisterViewController
        viewController?.viewModelRegister = self.viewModelLogin.setFBUserModal(resultDictionary: self.loggedInUserInfo)
        viewController?.isEmailEditable = false
        viewController?.socialToken = token
        viewController?.socialType = type
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func setUserData() {
        self.removeGuestData()
        UserDefaults.standard.setGuestCartCount(value: 0) // set guest cart count 0.
        self.requestForCreateCart()
    }
    
    func goToDashboard() {
        // move to dashboard/ Home
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TextField Delegates
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        actionDoneButton()
    }
    
    // Disable copy paste on password textField.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if passwordTextField.isFirstResponder {
            OperationQueue.main.addOperation({() -> Void in
                UIMenuController.shared.setMenuVisible(false, animated: false)
            })
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension LoginViewController: GIDSignInDelegate {
    // MARK: - Google SignIn
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        
        print("successfully LoggedIn")
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print("credential is: \(credential)")
        
        Auth.auth().signIn(with: credential) { (userInfo, error) in
            if let error = error {
                print("Failed to create google account. and the error is: \(error)")
                return
            }
            Auth.auth().currentUser?.reload()
            // User is signed in
            print("user Is Signed in")
            self.setValueInDict(userInfo: user!)
            // check isEmailAvailable or isAlready Signed in
            if let email = user.profile.email, let idToken = authentication.idToken {
                self.requestIsEmailAvailable(email: email, token: idToken, type: "google")
            } else {
                GIDSignIn.sharedInstance().signOut()
                Loader.shared.hideLoading()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error)
    }
    
    func setValueInDict(userInfo: GIDGoogleUser) {
        var userDict: [String: String?] = [:]
        
        let fullName = userInfo.profile.name
        let fullNameArr = fullName?.split {$0 == " "}.map(String.init)
        
        userDict["first_name"] = fullNameArr?.first ?? ""
        userDict["last_name"] = fullNameArr?.last ?? ""
        userDict["email"] = userInfo.profile.email ?? ""
        self.loggedInUserInfo = userDict as NSDictionary
    }
}

extension LoginViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

// MARK: - Facebook SignIn
extension LoginViewController {
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//
//        // ... Read permission
//    facebookSignUpButton.readPermissions = ["email", "public_profile", "basic_info"]
//        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large), friends, gender, age_range, birthday"]).start {(_, result, _) -> Void in
//            // (_, result, _) -> ((connection, result, error))
//            if let resultDictionary: NSDictionary = result as? NSDictionary {
//                print(resultDictionary)
//                self.loggedInUserInfo = resultDictionary
//            }
//        }
//        guard let FBToken = FBSDKAccessToken.current() else {
//            return
//        }
//        let credential = FacebookAuthProvider.credential(withAccessToken: FBToken.tokenString)
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//        Auth.auth().signIn(with: credential) { (user, error) in
//            if let error = error {
//                print("Error is: \(error.localizedDescription)")
//                return
//            }
//            // User is signed in
//            print("User is signed in")
//
//            // check isEmailAvailable or isAlready Signed in
//            if self.loggedInUserInfo.count > 0 && self.loggedInUserInfo.value(forKey: "email") != nil {
//                self.requestIsEmailAvailable(email: (self.loggedInUserInfo.value(forKey: "email") as? String)!, token: FBToken.tokenString, type: "facebook")
//            } else {
//                self.showAlertWith(title: AlertTitle.error, message: AlertValidation.somethingWentWrong, handler: { _ in
//                })
//            }
//        }
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        // facebook logout operation perform.
//    }
//}
//
//extension LoginViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollView.contentOffset.x = 0.0
//    }
}
