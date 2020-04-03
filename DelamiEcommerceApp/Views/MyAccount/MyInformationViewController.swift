//
//  MyInformationViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class MyInformationViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstNameTextField: BindingTextfield!
    @IBOutlet weak var lastNameTextField: BindingTextfield!
    @IBOutlet weak var emailTextField: BindingTextfield!
    
    @IBOutlet weak var phoneCodeTextField: BindingTextfield! {
        didSet {
            self.phoneCodeTextField.bind { self.viewModelMyInfo.phoneCode = $0 }
        }
    }
    @IBOutlet weak var phoneNumberTextField: BindingTextfield! {
        didSet {
            self.phoneNumberTextField.bind { self.viewModelMyInfo.phoneNumber = $0 }
        }
    }
    
    @IBOutlet weak var address1TextField: BindingTextfield!
    @IBOutlet weak var address2TextField: BindingTextfield!
    @IBOutlet weak var countryTextField: BindingTextfield!
    @IBOutlet weak var stateTextField: BindingTextfield!
    @IBOutlet weak var cityTextField: BindingTextfield!
    @IBOutlet weak var postalCodeTextFiels: BindingTextfield!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variable
    var viewModelMyInfo = MyInformationViewModel()
    var informationModel: MyInformationModel?
    
    var changedInTextField: Bool = false
    let pickerView = UIPickerView()
    var mobileCodeArray = [CountryModal]()
    
    // MARK: - API Call
    func requestForGetMyInformation() {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelMyInfo.requestForMyInfo(success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let data = response as? MyInformationModel {
                self?.informationModel = data
                self?.setUpData()
            }
            }, failure: { _ in
                Loader.shared.hideLoading()
        })
    }
    
    func requestForEditPhoneNumberInAddress() {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelMyInfo.requestForEditPhoneNumberInAddress(success: { [weak self] (_) in
            Loader.shared.hideLoading()
            self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertMessage.addressUpdatedSuccessfully.localized(), handler: { _ in
                 self?.navigationController?.popViewController(animated: true)
            })
            }, failure: { [weak self] _ in
                Loader.shared.hideLoading()
                self?.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeView()
        if self.informationModel != nil {
            setUpData()
        } else {
            requestForGetMyInformation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavigationTitle.myInformation.localized()
        addBackBtn(imageName: Image.back)
        containerViewHeightConstraint.constant = saveButton.frame.origin.y + saveButton.frame.height + 150
        scrollView.contentSize = CGSize(width: 0, height: containerViewHeightConstraint.constant)
    }
    
    // MARK: - View Setup
    func initializeView() {
        phoneCodeTextField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        loadMobileCode()
    }
    
    func loadMobileCode() {
        let countryData = CountryModal().loadJson(filename: "CountryCodes") ?? []
        mobileCodeArray = countryData.sorted(by: { $0.name! < $1.name! }) // Asceding order sorting
    }
    
    func setUpData() {
        firstNameTextField.text = self.informationModel?.firstname ?? ""
        lastNameTextField.text = self.informationModel?.lastname ?? ""
        emailTextField.text = self.informationModel?.email ?? ""
        
        if let defaultAddress = self.informationModel?.addresses?.filter({ $0.defaultShipping == true}).first {
            address1TextField.text = defaultAddress.street?.first ?? ""
            address2TextField.text = (defaultAddress.street?.count ?? 0) > 1 ? (defaultAddress.street?.last ?? "") : ""
            countryTextField.text = SystemConstant.defaultCountry.localized() // FIXME:-  According to code
            stateTextField.text = defaultAddress.region?.regionName ?? ""
            cityTextField.text = defaultAddress.city
            postalCodeTextFiels.text = defaultAddress.postcode
            
            if defaultAddress.telephone.contains("-") {
                let mobileNumber = defaultAddress.telephone.split(separator: "-").map(String.init)
                phoneCodeTextField.text = mobileNumber.first
                phoneNumberTextField.text = mobileNumber.last
                
            } else {
                phoneCodeTextField.text =  SystemConstant.defaultMobileCode
                phoneNumberTextField.text = defaultAddress.telephone
            }
        }
        // Set phone code and number in view model so that can not found nil
        viewModelMyInfo.phoneCode = phoneCodeTextField.text
        viewModelMyInfo.phoneNumber = phoneNumberTextField.text
    }
    
    // MARK: - Set Picker
    func setPickerView(textField: UITextField, tagValue: Int) {
        pickerView.delegate = self
        pickerView.tag = tagValue
        textField.inputView = pickerView
        textField.tintColor = .clear // hide the caret from textField.
    }
    
    // MARK: - button Action
    @IBAction func tapOnSaveButton(_ sender: Any) {
        if !changedInTextField {
            return
        } else {
        
        if viewModelMyInfo.performValidation() {
            // Call API
            requestForEditPhoneNumberInAddress()
        }
    }
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Picker View Datasource and Delegates
extension MyInformationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case PickerTag.mobileCode.rawValue:
            return mobileCodeArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case PickerTag.mobileCode.rawValue:
            
            guard let countryName = mobileCodeArray[row].name, let countryCode = mobileCodeArray[row].dial_code else {
                return ""
            }
            return countryName + "  ( " + countryCode + " )"
            
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // changedInTextField flag set because need to identify for api call that in picker there is any changes or not.
        changedInTextField = true
        saveButton.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.1254901961, blue: 0.1294117647, alpha: 1)
        
        switch pickerView.tag {
            
        case PickerTag.mobileCode.rawValue:
            guard let _ = mobileCodeArray[row].name, let countryCode = mobileCodeArray[row].dial_code else {
                return
            }
            phoneCodeTextField.text = countryCode
            self.viewModelMyInfo.phoneCode = phoneCodeTextField.text
            
        default:
            return
        }
    }
}

extension MyInformationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneCodeTextField {
            setPickerView(textField: textField, tagValue: PickerTag.mobileCode.rawValue)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // changedInTextField flag set because need to identify for api call that in picker there is any changes or not.
        changedInTextField = true
        saveButton.backgroundColor = #colorLiteral(red: 0.137254902, green: 0.1254901961, blue: 0.1294117647, alpha: 1)
        return true
    }
}

extension MyInformationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}
