//
//  NewsletterViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 15/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class NewsLetterViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: BindingTextfield! {
        didSet {
            self.emailTextField.bind { self.viewModelNewsLetter.emailID = $0 }
        }
    }
    @IBOutlet weak var subscribeButton: UIButton!
    
    // MARK: - Variables
    var viewModelNewsLetter = NewsLetterViewModel()
    
    // MARK: - API Call
    func requestForSubscription() {
        self.view.endEditing(true)
        weak var weakSelf = self
        
        Loader.shared.showLoading()
        viewModelNewsLetter.requestForSubscription(success: { (response) in
            Loader.shared.hideLoading()
            weakSelf?.showAlertWith(title: AlertTitle.success.localized(), message: response, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            })
            
        }, failure: { [weak self] (error) in
            Loader.shared.hideLoading()
            if error?.code == 404 {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Invalid.noUserExist.localized(), handler: { _ in
                })
            }
            if let errorMsg = error?.userInfo["message"] as? String {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: errorMsg, handler: { _ in
                })
            } else {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: self?.viewModelNewsLetter.apiError.message, handler: { _ in
                    
                })
            }
        })
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackBtn(imageName: Image.back)
        
        if let userEmail = UserDefaults.standard.getUserEmail() {
            emailTextField.text = userEmail
            viewModelNewsLetter.emailID = userEmail
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavTitles.newsLetter.localized()
        addBackBtn(imageName: Image.back)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button ACtion
    @IBAction func tapOnSubscribe(_ sender: Any) {
        if viewModelNewsLetter.performValidation() {
            // Call API
            requestForSubscription()
        } else {
            self.showAlertWith(title: AlertTitle.error.localized(), message: viewModelNewsLetter.rule.message, handler: { _ in
                
            })
        }
    }
}
