//
//  AddAddressViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class AddAddressViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstNameField: BindingTextfield! {
        didSet {
            self.firstNameField.bind { self.viewModelAddAddress.firstName = $0 }
        }
    }
    @IBOutlet weak var lastNameField: BindingTextfield! {
        didSet {
            self.lastNameField.bind { self.viewModelAddAddress.lastName = $0 }
        }
    }
    @IBOutlet weak var address1Field: BindingTextfield! {
        didSet {
            self.address1Field.bind { self.viewModelAddAddress.streetAddress1 = $0 }
        }
    }
    @IBOutlet weak var address2Field: BindingTextfield! {
        didSet {
            self.address2Field.bind { self.viewModelAddAddress.streetAddress2 = $0 }
        }
    }
    
    @IBOutlet weak var phoneCodeField: BindingTextfield! {
        didSet {
            self.phoneCodeField.bind { self.viewModelAddAddress.phoneCode = $0 }
        }
    }
    
    @IBOutlet weak var phoneNumberField: BindingTextfield! {
        didSet {
            self.phoneNumberField.bind { self.viewModelAddAddress.phoneNumber = $0 }
        }
    }
    
    @IBOutlet weak var countryField: BindingTextfield! {
        didSet {
            self.countryField.bind { self.viewModelAddAddress.country = $0 }
        }
    }
    @IBOutlet weak var stateField: BindingTextfield! {
        didSet {
            self.stateField.bind { self.viewModelAddAddress.state = $0 }
        }
    }
    @IBOutlet weak var cityField: BindingTextfield! {
        didSet {
            self.cityField.bind { self.viewModelAddAddress.city = $0 }
        }
    }
    @IBOutlet weak var postalCodeField: BindingTextfield! {
        didSet {
            self.postalCodeField.bind { self.viewModelAddAddress.postCode = $0 }
        }
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variables
    var viewModelAddAddress = AddAddressViewModel()
    var pickerView = UIPickerView()
    
    var changedInTextField: Bool = false
    var informationModel: InfoAddress?
    var countryData: [RegisterModel]?
    var cityData: [CityModel]?
    var selectedCountryIndex: Int = 0
    var comingFromScreen: String = ""
    var mobileCodeArray = [CountryModal]()
    
    // MARK: - API Call
    func requestForCountries() {
        viewModelAddAddress.requestForCountries(success: { (response) in
            if let countryData = response as? [RegisterModel] {
                self.countryData = countryData
            }
        }, failure: {
        })
    }
    
    func requestForCities(regionId: String) {
        viewModelAddAddress.requestForCities(regionId: regionId, success: { (response) in
            if let cityData = response as? [CityModel] {
                self.cityData = cityData
            }
        }, failure: {
        })
    }
    
    func requestForAddAddress(model: InfoAddress, addressIds: Int64) {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelAddAddress.requestForAddAddress(model: model, addressId: addressIds, success: { [weak self] _ in
            print(addressIds)
            Loader.shared.hideLoading()
            if addressIds == SystemConstant.defaultAddressId {
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertMessage.addressAddedSuccessfully.localized(), handler: {  _ in
                    self?.navigationController?.popViewController(animated: true)
                })
            } else {
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertMessage.addressUpdatedSuccessfully.localized(), handler: {  _ in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
            
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
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        requestForCountries()
        
        if self.informationModel != nil {
            setUpData()
        } else {
            loadPhoneNumber()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = comingFromScreen == ComingFromScreen.editAddress.rawValue ? NavigationTitle.editAddress.localized() : NavigationTitle.addAddress.localized()
        addBackBtn(imageName: Image.back)
        containerViewHeightConstraint.constant = saveButton.frame.origin.y + saveButton.frame.height + 150
        scrollView.contentSize = CGSize(width: 0, height: containerViewHeightConstraint.constant)
        saveButton.setTitle(ButtonTitles.save.localized(), for: .normal)
    }
    
    // MARK: - View Setup Methods
    func setUpData() {
        
        // requestForCities according to selected state
        if let regionId = self.informationModel?.regionId {
            requestForCities(regionId: String(regionId))
        }
        
        self.firstNameField.text = self.informationModel?.firstname ?? ""
        self.lastNameField.text = self.informationModel?.lastname ?? ""
        self.address1Field.text = self.informationModel?.street?.first ?? ""
        self.address2Field.text = (self.informationModel?.street?.count ?? 0) > 1 ? (self.informationModel?.street?.last ?? "") : ""
        self.countryField.text = SystemConstant.defaultCountry.localized()
        self.stateField.text = self.informationModel?.region?.regionName ?? ""
        self.cityField.text = self.informationModel?.city
        self.postalCodeField.text = self.informationModel?.postcode
        
        if (self.informationModel?.telephone.contains("-"))! {
            let mobileNumber = self.informationModel?.telephone.split(separator: "-").map(String.init)
            phoneCodeField.text = mobileNumber?.first
            phoneNumberField.text = mobileNumber?.last
            
        } else {
            phoneCodeField.text =  SystemConstant.defaultMobileCode
            phoneNumberField.text = self.informationModel?.telephone
        }
        
        viewModelAddAddress.firstName = self.firstNameField.text
        viewModelAddAddress.lastName = self.lastNameField.text
        viewModelAddAddress.streetAddress1 = self.address1Field.text
        viewModelAddAddress.streetAddress2 =  self.address2Field.text
        viewModelAddAddress.country = self.countryField.text
        viewModelAddAddress.state = self.stateField.text
        viewModelAddAddress.city = self.cityField.text
        viewModelAddAddress.selectedRegion = self.informationModel?.region
        viewModelAddAddress.selectedCountryId = (self.informationModel?.countryId)!
        viewModelAddAddress.postCode = self.postalCodeField.text
        viewModelAddAddress.phoneCode = phoneCodeField.text!
        viewModelAddAddress.phoneNumber = phoneNumberField.text
        
    }
    
    func loadPhoneNumber() {
        if let defaultAddress = DataStorage.instance.userAddressModel?.addresses?.filter({ $0.defaultShipping == true}).first {
            if defaultAddress.telephone.contains("-") {
                let mobileNumber = defaultAddress.telephone.split(separator: "-").map(String.init)
                phoneCodeField.text = mobileNumber.first
                phoneNumberField.text = mobileNumber.last
                
            } else {
                phoneCodeField.text =  SystemConstant.defaultMobileCode
                phoneNumberField.text = defaultAddress.telephone
            }
        }
        viewModelAddAddress.phoneCode = phoneCodeField.text!
        viewModelAddAddress.phoneNumber = phoneNumberField.text
    }
    
    func initializeView() {
        countryField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        stateField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        cityField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        phoneCodeField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        loadMobileCode()
    }
    
    // MARK: - set Picker
    func setPickerView(textField: UITextField, tagValue: Int) {
        pickerView.delegate = self
        pickerView.tag = tagValue
        textField.inputView = pickerView
        textField.tintColor = .clear // hide the caret from textField.
        // set first value from picker on textfield
        setFirstpickerValue()
    }
    
    func setFirstpickerValue() {
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
        self.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
    }
    
    func loadMobileCode() {
        let countryData = CountryModal().loadJson(filename: "CountryCodes") ?? []
        mobileCodeArray = countryData.sorted(by: { $0.name! < $1.name! }) // Asceding order sorting
    }
    
    // MARK: - Button Action
    @IBAction func tapOnSaveButton(_ sender: Any) {
        if  !changedInTextField {
            return
        } else {
            if viewModelAddAddress.performValidation() {
                // Call API
                var model = InfoAddress() // Create a reference for add and Edit both address cases , In case of add address create reference
                if self.informationModel != nil {
                    model = self.informationModel! // In cse of edit pass self.informationModel from previous VC i.e. addressBook VC
                }
                // Set values at place of default values in Model's object so we can pass it further.
                model.firstname = viewModelAddAddress.firstName ?? ""
                model.lastname = viewModelAddAddress.lastName ?? ""
                model.street?.removeAll()
                model.street = []
                
                model.street?.insert(viewModelAddAddress.streetAddress1 ?? "", at: 0)
                model.street?.insert(viewModelAddAddress.streetAddress2 ?? "", at: 1)
                model.countryId = viewModelAddAddress.selectedCountryId
                
                if let phoneNumber = viewModelAddAddress.phoneNumber {
                    model.telephone = viewModelAddAddress.phoneCode + "-" + phoneNumber
                } else {
                    model.telephone = viewModelAddAddress.phoneCode
                }
                
                model.city = viewModelAddAddress.city ?? ""
                model.postcode = viewModelAddAddress.postCode ?? ""
                model.regionId = viewModelAddAddress.selectedRegion?.regionId ?? 0
                model.region = viewModelAddAddress.selectedRegion
                if let addressId = model.addressId {
                    requestForAddAddress(model: model, addressIds: addressId)
                }

            } else {
                self.showAlertWith(title: AlertTitle.error.localized(), message: viewModelAddAddress.rule.message, handler: { _ in
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AddAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == countryField {
            setPickerView(textField: textField, tagValue: PickerTag.country.rawValue)
        } else  if textField == stateField {
            setPickerView(textField: textField, tagValue: PickerTag.state.rawValue)
        } else if textField == cityField {
            setPickerView(textField: textField, tagValue: PickerTag.city.rawValue)
        } else if textField == phoneCodeField {
            setPickerView(textField: textField, tagValue: PickerTag.mobileCode.rawValue)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // changedInTextField flag set because need to identify for api call that in picker there is any changes or not.
        changedInTextField = true
        saveButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        return true
    }
}

extension AddAddressViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

// MARK: - Picker View Datasource and Delegates
extension AddAddressViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case PickerTag.mobileCode.rawValue:
            return mobileCodeArray.count
        case PickerTag.country.rawValue:
            return countryData?.count ?? 0
        case PickerTag.state.rawValue:
            return countryData?[selectedCountryIndex].availableRegions?.count ?? 0
        case PickerTag.city.rawValue:
            return cityData?.count ?? 0
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
            
        case PickerTag.country.rawValue:
            return String(format: countryData?[row].fullNameLocal ?? "")
        case PickerTag.state.rawValue:
            return String(format: countryData?[selectedCountryIndex].availableRegions?[row].name ?? "")
        case PickerTag.city.rawValue:
            return String(format: cityData?[row].name ?? "")
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // changedInTextField flag set because need to identify for api call that in picker there is any changes or not.
        changedInTextField = true
        saveButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        
        switch pickerView.tag {
        case PickerTag.mobileCode.rawValue:            
            guard let _ = mobileCodeArray[row].name, let countryCode = mobileCodeArray[row].dial_code else {
                return
            }
            phoneCodeField.text = countryCode
            self.viewModelAddAddress.phoneCode = countryCode
            
        case PickerTag.country.rawValue:
            if countryData != nil {
                countryField.text = String(format: countryData![row].fullNameLocal)
                self.viewModelAddAddress.country = String(format: countryData![row].fullNameLocal)
                
                self.selectedCountryIndex = row
                self.viewModelAddAddress.selectedCountryId = String(format: countryData![row].identifier)
            } else {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.NoDataAvailable.country.localized(), handler: {_ in
                })
            }
            
        case PickerTag.state.rawValue:
            if countryData != nil {
                stateField.text = String(format: countryData![selectedCountryIndex].availableRegions![row].name)
                self.viewModelAddAddress.state = String(format: countryData![selectedCountryIndex].availableRegions![row].name)
                
                // requestForCities according to selected state
                requestForCities(regionId: countryData![selectedCountryIndex].availableRegions![row].regionId)
                
                var region = Region()
                region.regionCode = countryData![selectedCountryIndex].availableRegions![row].code
                region.regionName = countryData![selectedCountryIndex].availableRegions![row].name
                region.regionId = Int64(countryData![selectedCountryIndex].availableRegions![row].regionId)!
                
                self.viewModelAddAddress.selectedRegion = region
                //                self.viewModelAddAddress.selectedRegion = countryData![selectedCountryIndex].availableRegions![row]
            }
            
        case PickerTag.city.rawValue:
            if cityData != nil {
                cityField.text = String(format: cityData![row].name)
                self.viewModelAddAddress.city = String(format: cityData![row].name)
            } else {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.noCityForState.localized(), handler: {_ in
                })
            }
        default:
            return
        }
    }
}
