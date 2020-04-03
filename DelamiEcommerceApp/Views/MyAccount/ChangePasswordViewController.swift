//
//  ChangePasswordViewController.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/9/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ChangePasswordViewController: DelamiViewController {
    @IBOutlet weak var currentPasswordTextField: BindingTextfield! {
        didSet {
            self.currentPasswordTextField.bind { self.viewModelChangePassword.currentpassword = $0 }
        }
    }
    @IBOutlet weak var newPasswordTextField: BindingTextfield! {
        didSet {
            self.newPasswordTextField.bind { self.viewModelChangePassword.newPassword = $0 }
        }
    }
    @IBOutlet weak var confirmNewPassTextField: BindingTextfield! {
        didSet {
            self.confirmNewPassTextField.bind { self.viewModelChangePassword.confirmNewPass = $0 }
        }
    }
    @IBOutlet weak var submitButton: UIButton!

    var viewModelChangePassword = ChangePasswordViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavTitles.changePassword.localized()
        addBackBtn(imageName: Image.back)
    }

    @IBAction func submitAction(_ sender: UIButton) {
        if viewModelChangePassword.performValidation() {
            // Call API
            requestToChangePassword()
        } else {
            self.showAlertWith(title: AlertTitle.error, message: viewModelChangePassword.rule.message, handler: { _ in
            })
        }
    }
    
    func requestToChangePassword() {
        self.view.endEditing(true)
        weak var weakSelf = self
        Loader.shared.showLoading()
        viewModelChangePassword.requestForChangePassword(success: { (_) in
            Loader.shared.hideLoading()
            weakSelf?.showAlertWith(title: AlertTitle.success.localized(), message: AlertMessage.passwordChange.localized(), handler: {_ in
                self.navigationController?.popViewController(animated: true)
            })
        }, failure: { [weak self] (error) in
            Loader.shared.hideLoading()
            if let errorMsg = error?.userInfo["message"] {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                })
            } else {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                })
            }
        })
    }
}
