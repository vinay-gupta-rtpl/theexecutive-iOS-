//
//  ForgotPasswordViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 28/02/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTextField: BindingTextfield! {
        didSet {
            self.emailTextField.bind { self.viewModelForgotPassword.emailID = $0 }
        }
    }
    
    // MARK: - Variables
    var viewModelForgotPassword = ForgotPasswordViewModal()
    
    // MARK: - API Call
    func requestForForgotPassword() {
        self.view.endEditing(true)
        weak var weakSelf = self
        
        Loader.shared.showLoading()
        viewModelForgotPassword.requestForForgotPassword(success: { (response) in
            Loader.shared.hideLoading()
            if response {
                // Mail sent successfully
                weakSelf?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.mailSent.localized(), handler: {_ in
                self.navigationController?.popViewController(animated: true)
                })
            } else {
                // mail did not send successfully.
                weakSelf?.showAlertWith(title: AlertTitle.error.localized(), message: AlertFailureMessage.mailNotSent.localized(), handler: { _ in
                })
            }
        }, failure: { [weak self] (error) in
            Loader.shared.hideLoading()
            if error.code == 404 {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Invalid.noUserExist.localized(), handler: { _ in
                })
            }
            if let errorMsg = error.userInfo["message"] as? String {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: errorMsg, handler: { _ in
                })
            } else {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: self?.viewModelForgotPassword.apiError.message, handler: { _ in
                    
                })
            }
        })
    }
    
    // MARK: - View cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NavigationTitle.forgotPassword.localized()
        addBackBtn(imageName: Image.back)
        initializeView()
    }
    
    // MARK: - View setup
    func initializeView() {
        // tap gesture on view
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionDoneButton))
        view.addGestureRecognizer(tap)
    }
    
    @objc func actionDoneButton() {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func submitButtonAction(_ sender: Any) {
        if self.viewModelForgotPassword.performValidation() {
            // Call API
            requestForForgotPassword()
        } else {
            self.showAlertWith(title: AlertTitle.error.localized(), message: viewModelForgotPassword.rule.message, handler: { _ in
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - TextField Delegates
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        actionDoneButton()
    }
}
