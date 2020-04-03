//
//  RegisterViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 01/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import UIKit
import TTTAttributedLabel

class RegisterViewController: DelamiViewController {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var containerChildView: UIView!
    @IBOutlet weak var scrollChildViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var firstNameTextField: BindingTextfield! {
        didSet {
            self.firstNameTextField.bind { self.viewModelRegister?.firstName = $0 }
        }
    }
    @IBOutlet weak var lastNameTextField: BindingTextfield! {
        didSet {
            self.lastNameTextField.bind { self.viewModelRegister?.lastName = $0 }
        }
    }
    @IBOutlet weak var emailTextField: BindingTextfield! {
        didSet {
            self.emailTextField.bind { self.viewModelRegister?.emailID = $0 }
        }
    }
    @IBOutlet weak var mobileCodeTextField: BindingTextfield! {
        didSet {
            self.mobileCodeTextField.bind { self.viewModelRegister?.mobileCode = $0 }
        }
    }
    @IBOutlet weak var mobileNoTextField: BindingTextfield! {
        didSet {
            self.mobileNoTextField.bind { self.viewModelRegister?.mobileNumber = $0 }
        }
    }
    @IBOutlet weak var addressFirstTextField: BindingTextfield! {
        didSet {
            self.addressFirstTextField.bind { self.viewModelRegister?.streetAddressLine1 = $0 }
        }
    }
    @IBOutlet weak var addressSecondTextField: BindingTextfield! {
        didSet {
            self.addressSecondTextField.bind { self.viewModelRegister?.streetAddressLine2 = $0 }
        }
    }
    @IBOutlet weak var countryTextField: BindingTextfield! {
        didSet {
            self.countryTextField.bind { self.viewModelRegister?.country = $0 }
        }
    }
    @IBOutlet weak var stateTextField: BindingTextfield! {
        didSet {
            self.stateTextField.bind { self.viewModelRegister?.state = $0 }
        }
    }
    @IBOutlet weak var cityTextField: BindingTextfield! {
        didSet {
            self.cityTextField.bind { self.viewModelRegister?.city = $0 }
        }
    }
    @IBOutlet weak var postcodeTextField: BindingTextfield! {
        didSet {
            self.postcodeTextField.bind { self.viewModelRegister?.postCode = $0 }
        }
    }
    @IBOutlet weak var birthDateTextField: BindingTextfield! {
        didSet {
            self.birthDateTextField.bind { self.viewModelRegister?.birthDate = $0 }
        }
    }
    @IBOutlet weak var passwordTextField: BindingTextfield! {
        didSet {
            self.passwordTextField.bind { self.viewModelRegister?.password = $0 }
        }
    }
    @IBOutlet weak var confirmPasswordTextField: BindingTextfield! {
        didSet {
            self.confirmPasswordTextField.bind { self.viewModelRegister?.confirmPassword = $0 }
        }
    }
    @IBOutlet weak var maleGenderView: UIView!
    @IBOutlet weak var femaleGenderView: UIView!
    @IBOutlet weak var femaleGenderButton: UIButton!
    @IBOutlet weak var maleGenderButton: UIButton!
    @IBOutlet weak var femaleGenderLabel: UILabel!
    @IBOutlet weak var maleGenderLabel: UILabel!
    @IBOutlet weak var checkboxSubscribeButton: UIButton!
    @IBOutlet weak var termsConditionsLabel: TTTAttributedLabel!
    @IBOutlet weak var subscripitionLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var customDatePickerView: UIView!
    @IBOutlet weak var customToolBar: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    // MARK: - Variables
    let pickerView = UIPickerView()
    let toolbarView = UIView()
    var viewModelRegister: RegisterViewModal?
    var labelPositionChanged: Bool = false
    var isEmailEditable: Bool = true
    var socialToken: String = ""
    var socialType: String = ""
    var mobileCodeArray = [CountryModal]()
    
    var countryData: [RegisterModel]?
    var cityData: [CityModel]?
    var selectedCountryIndex: Int = 1
    var selectedStateIndex: Int = 1
    var globalAttributedString: NSMutableAttributedString?
    
    // MARK: - API call
    func requestForSocialLogin(email: String, token: String, loginType: String) {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        
        viewModelRegister?.requestForSocialLogin(email: email, token: token, loginType: loginType, success: {
            Loader.shared.hideLoading()
            // check for merge cart
            if let guestCartToken = UserDefaults.standard.getGuestCartToken() {
                LoginViewModel().mergeGuestCartToUser(guestCartId: guestCartToken, success: { _ in
                }, failure: { _ in
                })
            }
            
            // In case of Social login move to Home view controller
            self.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.socialLogin.localized(), handler: {_ in
                // move to dashboard/ Home
                if let tabbar = appDelegate.window?.rootViewController as? UITabBarController {
                    tabbar.selectedIndex = 0
                }
                
                UserDefaults().clearGuestDefaultData()
                self.view.endEditing(true)
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }, failure: { (error) in
            Loader.shared.hideLoading()
            // not logged in successfully.
            if let msgStr = error.userInfo["message"] as? String {
                self.showAlertWith(title: AlertTitle.error.localized(), message: msgStr, handler: { _ in })
            }
            print(error)
        })
    }
    
    func requestForRegistration() {
        self.view.endEditing(true)
        weak var weakSelf = self
        
        Loader.shared.showLoading()
        viewModelRegister?.requestForRegister(success: { (response) in
            Loader.shared.hideLoading()
            if response == LoginType.social.rawValue {
                //API call to Social Login
                self.requestForSocialLogin(email: self.emailTextField.text!, token: self.socialToken, loginType: self.socialType)
                
            } else if response == LoginType.normal.rawValue {
                // In case of normal login move to login view controller
                weakSelf?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.login.localized(), handler: {_ in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }, failure: {[weak self] (error) in
            Loader.shared.hideLoading()
            if let statusCode = error?.code, statusCode == 400 {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertFailureMessage.userAlreadyExist.localized(), handler: { _ in
                })
            } else {
                if let errorMsg = error?.userInfo["message"] {
                    weakSelf?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                } else {
                    weakSelf?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                    })
                }
            }
        })
    }
    
    func requestForCountries() {
        viewModelRegister?.requestForCountries(success: { (response) in
            if let countryData = response as? [RegisterModel] {
                self.countryData = countryData
            }
        }, failure: {
        })
    }
    
    func requestForCities(regionId: String) {
        viewModelRegister?.requestForCities(regionId: regionId, success: { (response) in
            if let cityData = response as? [CityModel] {
                self.cityData = cityData
            }
        }, failure: {
        })
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = NavigationTitle.registration.localized()
        
        // API calling
        requestForCountries()
        
        // setting Fb fetched data to register text fields.
        if let fbModel = viewModelRegister {
            setFbUserInfo(fbUserModel: fbModel)
        }
        
        initializeView()
        genderTapGesture()
        loadMobileCode()
    }
    
    func setUpPrivacyPolicyLabel() {
        termsConditionsLabel.delegate = self
        // define warning range
        
        let text = ConstantString.termsAndConditionFullString.localized()
        termsConditionsLabel.font = FontUtility.regularFontWithSize(size: 16.0)
        termsConditionsLabel.textColor = #colorLiteral(red: 0.08208550513, green: 0.08208550513, blue: 0.08208550513, alpha: 1)
        
        let myString = NSMutableAttributedString(string: text)
        // define price range
        let str = NSString(string: text)
        
        let termConditionRange = str.range(of: ConstantString.termsAndCondition.localized())
//        let privacyPolicyRange = str.range(of: ConstantString.privacyPolicy.localized())
        let completeRange = str.range(of: ConstantString.termsAndConditionFullString.localized())
        
        myString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 16.0), range: completeRange)
        
        let linkAttr = [
            NSAttributedStringKey.font: FontUtility.mediumFontWithSize(size: 16.0),
            NSAttributedStringKey.underlineStyle: true
            ] as [NSAttributedStringKey: Any]
        
        termsConditionsLabel.attributedText = myString
        termsConditionsLabel.numberOfLines = 0
        termsConditionsLabel.lineBreakMode = .byWordWrapping
        
        termsConditionsLabel.isUserInteractionEnabled = true
        termsConditionsLabel.linkAttributes = linkAttr
        termsConditionsLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.top
        termsConditionsLabel.activeLinkAttributes = linkAttr
        termsConditionsLabel.addLink(to: URL(string: ""), with: termConditionRange)
//        termsConditionsLabel.addLink(to: URL(string: ""), with: privacyPolicyRange)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NavigationTitle.registration.localized()
        addBackBtn(imageName: Image.back)
        setUpPrivacyPolicyLabel()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollChildViewHeightConstraints.constant = 1450
        
        scrollView.contentSize = CGSize(width: 0, height: scrollChildViewHeightConstraints.constant)

    }
    
    // MARK: - View Setup Methods
    func initializeView() {
        setUpDatePicker()
        
        countryTextField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        stateTextField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        cityTextField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        mobileCodeTextField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        birthDateTextField.setRightViewImage(image: #imageLiteral(resourceName: "calender"))
        checkboxSubscribeButton.setBackgroundImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        
        if isEmailEditable {
            emailTextField.isUserInteractionEnabled = true
        } else {
            emailTextField.isUserInteractionEnabled = false
        }
        
        subscripitionLabel.text = AppConfigurationModel.sharedInstance.subscriptionMessage ?? ""
        mobileCodeTextField.text = SystemConstant.defaultMobileCode
//        maleGenderButton.isSelected = true // default selet male gender
    }
    
    func setUpDatePicker() {
        // button for open date picker
        let datePickerButton = UIButton(frame: self.birthDateTextField.bounds)
        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        self.birthDateTextField.addSubview(datePickerButton)
        
        let currentDate: NSDate = NSDate()
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar as Calendar
        
        components.year = -80
        let minDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        components.year = -13
        let maxDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        self.datePicker.minimumDate = minDate as Date
        self.datePicker.maximumDate = maxDate as Date
    }
    
    @objc func showDatePicker() {
        self.view.endEditing(true)
        self.customDatePickerView.isHidden = false
    }
    
    func setFirstpickerValue() {
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
        self.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
    }
    
  /*  func loadMobileCode() {
        if let path = Bundle.main.path(forResource: "MobileCode", ofType: "plist") {
            if let arrayOfDictionaries = NSArray(contentsOfFile: path) {
//                for dict in arrayOfDictionaries {
//                    mobileCodeArray.add((((dict as? NSDictionary)!).object(forKey: "phone_code") as? NSNumber)!)
//                }
         mobileCodeArray = (arrayOfDictionaries.mutableCopy() as? NSMutableArray)!
            }
        }
    }*/
    
    func loadMobileCode() {
        let countryData = CountryModal().loadJson(filename: "CountryCodes") ?? []
        mobileCodeArray = countryData.sorted(by: { $0.name! < $1.name! }) // Asceding order sorting
    }
    
    // MARK: - male or female
    func genderTapGesture() {
        let maleTapGesture = UITapGestureRecognizer(target: self, action: #selector(genderTapAction(sender:)))
        maleGenderView.addGestureRecognizer(maleTapGesture)
        let femaleTapGesture = UITapGestureRecognizer(target: self, action: #selector(genderTapAction(sender:)))
        femaleGenderView.addGestureRecognizer(femaleTapGesture)
    }
    
    // TAp gesture for male and female view
    @objc func genderTapAction(sender: UITapGestureRecognizer? = nil) {
        if sender?.view == maleGenderView {
            maleGenderSelected()
        } else if sender?.view == femaleGenderView {
            femaleGenderSelected()
        }
    }
    
    func maleGenderSelected () {
        viewModelRegister?.gender = Gender.male.rawValue
        maleGenderButton.isSelected = true
        femaleGenderButton.isSelected = false
    }
    
    func femaleGenderSelected() {
        viewModelRegister?.gender = Gender.female.rawValue
        femaleGenderButton.isSelected = true
        maleGenderButton.isSelected = false
    }
    
    @IBAction func genderSelectionAction(_ sender: UIButton) {
        switch sender.tag {
        case 1: // male Gender Selected
            maleGenderSelected ()
        case 2: // Female gender selected
            femaleGenderSelected()
        default:
            return
        }
    }
    
    func tapOnTermsAndPolicy() {
        guard let link = AppConfigurationModel.sharedInstance.termsAndConditionURL, let linkURL = NSURL(string: link) as URL? else {
            return
        }
        
        if link != "" {
            if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
                webController.url = linkURL
                webController.navigationTitle = NavigationTitle.termsAndCondition.localized()
                let navigationController = UINavigationController(rootViewController: webController)
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Set Date Picker
    func setPickerView(textField: UITextField, tagValue: Int) {
        pickerView.delegate = self
        pickerView.tag = tagValue
        textField.inputView = pickerView
        textField.tintColor = .clear // hide the caret from textField.
        setFirstpickerValue() // set first value from picker on textfield
    }
    
    func setFbUserInfo(fbUserModel: RegisterViewModal) {
        self.firstNameTextField.text = fbUserModel.firstName
        self.lastNameTextField.text = fbUserModel.lastName
        self.emailTextField.text = fbUserModel.emailID
    }
    
    @IBAction func subscriptionAction(_ sender: Any) {
        var isSubscribed: Bool = false
        if (checkboxSubscribeButton.currentBackgroundImage?.isEqual(#imageLiteral(resourceName: "checkbox")))! {
            isSubscribed = true
            checkboxSubscribeButton.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
        } else {
            isSubscribed = false
            checkboxSubscribeButton.setBackgroundImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        }
        viewModelRegister?.isSubscribed = isSubscribed
    }
    
    @IBAction func tapOnCreateAccount(_ sender: Any) {
        if (viewModelRegister?.performValidation())! {
            // Call API
            requestForRegistration()
        } else {
            self.showAlertWith(title: AlertTitle.error.localized(), message: viewModelRegister?.rule.message, handler: { _ in
            })
        }
    }
    
    @IBAction func datePickerAction(_ sender: Any) {
        birthDateTextField.tintColor = .clear // hide the caret from textField.
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: (sender as AnyObject).date)
//        if let _ = components.day, let _ = components.month, let _ = components.year {
        if components.day != nil, components.month != nil, components.year != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SystemConstant.datePatternPresentingWay // "dd/MM/YYYY"
            birthDateTextField.text = dateFormatter.string(from: (sender as AnyObject).date)
            
            let dateFormatterForAPI = DateFormatter()
            dateFormatterForAPI.dateFormat = SystemConstant.dateFormatterPattern // "dd-MM-YYYY"
            viewModelRegister?.birthDate = dateFormatterForAPI.string(from: (sender as AnyObject).date)
        }
    }
    
    @IBAction func datePickerDoneAction(_ sender: Any) {
        if birthDateTextField.isEmpty() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SystemConstant.datePatternPresentingWay // "dd/MM/YYYY"
            birthDateTextField.text = dateFormatter.string(from: datePicker.date)
            // set birthdate on view model
            let anotherDateFormatter = DateFormatter()
            anotherDateFormatter.dateFormat = SystemConstant.dateFormatterPattern //"dd-MM-YYYY"
            viewModelRegister?.birthDate = anotherDateFormatter.string(from: datePicker.date)
        }
        self.view.endEditing(true)
        self.customDatePickerView.isHidden = true
    }
}

// MARK: - Picker View Datasource and Delegates
extension RegisterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
//            return String(describing: mobileCodeArray[row])
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
        switch pickerView.tag {
        case PickerTag.mobileCode.rawValue:
//            mobileCodeTextField.text = SystemConstant.plus + String(describing: mobileCodeArray[row])
            
            guard mobileCodeArray[row].name != nil, let countryCode = mobileCodeArray[row].dial_code else {
               return
            }
            mobileCodeTextField.text = countryCode
            self.viewModelRegister?.mobileCode = countryCode
            
        case PickerTag.country.rawValue:
            if countryData != nil {
                countryTextField.text = String(format: countryData![row].fullNameLocal)
                self.viewModelRegister?.country = String(format: countryData![row].fullNameLocal)
                
                self.selectedCountryIndex = row
                self.viewModelRegister?.selectedCountryId = String(format: countryData![row].identifier)
                
            } else {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.NoDataAvailable.country.localized(), handler: {_ in
                })
            }
            
        case PickerTag.state.rawValue:
            if countryData != nil {
                stateTextField.text = String(format: countryData![selectedCountryIndex].availableRegions![row].name)
                self.viewModelRegister?.state = String(format: countryData![selectedCountryIndex].availableRegions![row].name)
                
                // requestForCities according to selected state
                requestForCities(regionId: countryData![selectedCountryIndex].availableRegions![row].regionId)
                
                self.viewModelRegister?.selectedRegion = countryData![selectedCountryIndex].availableRegions![row]
            }
            
        case PickerTag.city.rawValue:
            if cityData != nil {
                cityTextField.text = String(format: cityData![row].name)
                self.viewModelRegister?.city = String(format: cityData![row].name)
            } else {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.noCityForState.localized(), handler: {_ in
                })
            }
        default:
            return
            
        }
    }
}

// MARK: - TextFields Delegates
extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.customDatePickerView.isHidden = true
        
        if textField == countryTextField {
            setPickerView(textField: textField, tagValue: PickerTag.country.rawValue)
            
        } else if textField == mobileCodeTextField {
            setPickerView(textField: textField, tagValue: PickerTag.mobileCode.rawValue)
            
        } else if textField == cityTextField {
            if countryTextField.isEmpty() {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.country.localized(), handler: {_ in
                    
                })
            } else if stateTextField.isEmpty() {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.state.localized(), handler: {_ in
                    
                })
            } else {
                setPickerView(textField: textField, tagValue: PickerTag.city.rawValue)
            }
            
        } else if textField == stateTextField {
            if countryTextField.isEmpty() {
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.country.localized(), handler: {_ in
                    
                })
            } else {
                setPickerView(textField: textField, tagValue: PickerTag.state.rawValue)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstNameTextField {
            let maxLength = 50
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if textField == mobileNoTextField || textField == postcodeTextField {
            let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.view.endEditing(true)
    }
}

extension RegisterViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

extension RegisterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

extension RegisterViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        tapOnTermsAndPolicy()
    }
}
