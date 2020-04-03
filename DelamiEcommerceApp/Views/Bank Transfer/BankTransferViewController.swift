//
//  BankTransferViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 28/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
class BankTransferViewController: ImagePickerController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstNameTextField: BindingTextfield! {
        didSet {
            self.firstNameTextField.bind { self.viewModelBankTransfer.firstName = $0 }
        }
    }
    @IBOutlet weak var lastNameTextField: BindingTextfield! {
        didSet {
            self.lastNameTextField.bind { self.viewModelBankTransfer.lastName = $0 }
        }
    }
    @IBOutlet weak var emailAddressTextField: BindingTextfield! {
        didSet {
            self.emailAddressTextField.bind { self.viewModelBankTransfer.emailID = $0 }
        }
    }
    @IBOutlet weak var orderNumberField: BindingTextfield! {
        didSet {
            self.orderNumberField.bind { self.viewModelBankTransfer.orderNumber = $0 }
        }
    }
    @IBOutlet weak var bankNumberField: BindingTextfield! {
        didSet {
            self.bankNumberField.bind { self.viewModelBankTransfer.bankNumber = $0 }
        }
    }
    @IBOutlet weak var holderAccountNumberField: BindingTextfield! {
        didSet {
            self.holderAccountNumberField.bind { self.viewModelBankTransfer.holderAccountNumber = $0 }
        }
    }
    @IBOutlet weak var transferAmountField: BindingTextfield! {
        didSet {
            self.transferAmountField.bind { self.viewModelBankTransfer.transferAmount = $0 }
        }
    }
    @IBOutlet weak var bankRecipientField: BindingTextfield! {
        didSet {
            self.bankRecipientField.bind { self.viewModelBankTransfer.bankRecipient = $0 }
        }
    }
    @IBOutlet weak var transferMethodField: BindingTextfield! {
        didSet {
            self.transferMethodField.bind { self.viewModelBankTransfer.transferMethod = $0 }
        }
    }
    @IBOutlet weak var transferDateField: BindingTextfield! {
        didSet {
            self.transferDateField.bind { self.viewModelBankTransfer.transferDate = $0 }
        }
    }
    @IBOutlet weak var deleteAttachmentButton: UIButton!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Variables
    var viewModelBankTransfer = BankTransferViewModel()
    let pickerView = UIPickerView()
    var informationModel: MyInformationModel?
    var lastSelectedDate: Date?
    
    // MARK: - API Call
    func requestForGetMyInformation() {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelBankTransfer.requestForMyInfo(success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let data = response as? MyInformationModel {
                self?.informationModel = data
            }
            }, failure: { _ in
                Loader.shared.hideLoading()
        })
    }
    
    func getBankTransferMethods(type: BankTransfer) {
        BankTransferModel().getTransferMethod(forType: type, success: { (_) in
        }, failure: { (_) in
        })
    }
    
    func requestForBankTransfer() {
        self.view.endEditing(true)
        Loader.shared.showLoading()
        viewModelBankTransfer.requestForBankTransfer(success: { [weak self] response in
            Loader.shared.hideLoading()
            
            self?.showAlertWith(title: AlertTitle.none, message: response, handler: { _ in
                self?.navigationController?.popViewController(animated: true)
            })
            }, failure: { [weak self] (error) in
                Loader.shared.hideLoading()
                if let errorMsg = error.userInfo["message"] {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                } else {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                    })
                }
        })
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        // auto filled name and email in bank transfer form
        if let addressModel = DataStorage.instance.userAddressModel {
            self.informationModel = addressModel
            autoFilledFields()
        } else {
            requestForGetMyInformation()
        }
        
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
        
        self.navigationItem.title = NavigationTitle.bankTransferConfirmation.localized()
        self.addBackBtn(imageName: Image.back)
        self.tabBarController?.tabBar.isHidden = true
        containerViewHeightConstraint.constant = self.submitButton.frame.origin.y + submitButton.frame.height + 200
        scrollView.contentSize = CGSize(width: 0, height: containerViewHeightConstraint.constant)
        
        self.view.updateStringsForApplicationGlobalLanguage()
    }
    
    func autoFilledFields() {
        self.firstNameTextField.text = self.informationModel?.firstname
        self.lastNameTextField.text = self.informationModel?.lastname
        self.emailAddressTextField.text = self.informationModel?.email
        
        self.viewModelBankTransfer.firstName = self.firstNameTextField.text!
        self.viewModelBankTransfer.lastName = self.lastNameTextField.text!
        self.viewModelBankTransfer.emailID = self.emailAddressTextField.text!
    }
    
    // MARK: - Navigation Back Button setUp
    //because here parent class is ImagePickerController not DelamiViewController
    func addBackBtn(imageName: UIImage) {
        let leftBarBtn = UIButton()
        leftBarBtn.setImage(imageName, for: .normal)
        leftBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftBarBtn.setTitleColor(.black, for: .normal)
        leftBarBtn.addTarget(self, action: #selector(actionBackButton), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarBtn)
    }
    
    @objc func actionBackButton() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View SetUp
    func setUpUI() {
        // tap gesture to resignFirstResponder.
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionDoneButton))
        view.addGestureRecognizer(tap)
        
        self.showDottedLine()
        attachmentImageView.image = Image.addAttachmentImage
        attachmentImageView.layer.borderWidth = 0.4
        attachmentImageView.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        transferMethodField.setRightViewImage(image: #imageLiteral(resourceName: "dropdown"))
        transferDateField.setRightViewImage(image: #imageLiteral(resourceName: "calender"))

        // show default today's date on transferDateField.
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = SystemConstant.datePatternPresentingWay //"dd/MM/YYYY"
        
        transferDateField.text = dateFormatter.string(from: datePickerView.date)
        self.viewModelBankTransfer.transferDate = transferDateField.text!
        
        // set bank receipt text
        guard let bankRecipientArray =  DataStorage.instance.bankRecipient else {
            return
        }
        self.bankRecipientField.text = bankRecipientArray.first?.label
        self.viewModelBankTransfer.bankRecipient = self.bankRecipientField.text!
    }
    
    func showDottedLine() {
        let imageViewBorder = CAShapeLayer()
        imageViewBorder.strokeColor = UIColor.black.cgColor
        imageViewBorder.lineDashPattern = [2, 2]
        imageViewBorder.frame = attachmentImageView.bounds
        imageViewBorder.fillColor = nil
        imageViewBorder.path = UIBezierPath(rect: attachmentImageView.bounds).cgPath
        attachmentImageView.layer.addSublayer(imageViewBorder)
    }
    
    func setDatePicker(textField: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = NSDate() as Date
        textField.inputView = datePickerView
        textField.tintColor = .clear
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = SystemConstant.datePatternPresentingWay //"dd/MM/YYYY"
        
        if transferDateField.isEmpty() {
            transferDateField.text = dateFormatter.string(from: datePickerView.date)
            self.viewModelBankTransfer.transferDate = transferDateField.text!
        } else {
            if let selectedDate = lastSelectedDate {
                datePickerView.setDate(selectedDate, animated: true)
            }
        }
    }
    
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
    
    // MARK: - Image Cropper/Image Picker Open when Click on Image View for adding attachment.
    @IBAction func tapOnAttachmentImageView(_ sender: UITapGestureRecognizer) {
        if imageMatchWithPlus() {
            loadImagePicker()  //  no image on attachment image view so load action sheet
        } else { // Image already present so view image
            if let image = attachmentImageView.image {
                UIView().funcZoomInOut(image: image, crossImage: #imageLiteral(resourceName: "cancel"))
            }
        }
    }
    
    func loadImagePicker() {
        var isPhotoAvailable: Bool = false
        isPhotoAvailable = !imageMatchWithPlus()
        
        let width = MainScreen.width - 70
        let height = (width * 6) / 5
        
        self.loadImagePicker(cameraAccess: true, galleryAccess: true, ovalCrop: false, cropSize: CGSize(width: width, height: height), selectMessage: AlertMessage.UploadAttachmentPhotoMessage.localized(), photoAvailable: isPhotoAvailable)
    }
    
    override func iImagePickerController(_ imagePicker: ImagePickerController!, croppedImage: UIImage!) {
        if let image = croppedImage {
            attachmentImageView.image = image
            attachmentImageView.contentMode = .scaleAspectFill
            deleteAttachmentButton.isHidden = false
        }
    }
    
    func imageMatchWithPlus() -> Bool {
        let imagePlus: NSData = UIImagePNGRepresentation(Image.addAttachmentImage)! as NSData
        let image: NSData = UIImagePNGRepresentation(attachmentImageView.image!)! as NSData
        return imagePlus.isEqual(image)
    }
    
    // MARK: - Button Actions
    @IBAction func deleteAttachmentAction(_ sender: Any) {
        deleteAttachmentButton.isHidden = true
        attachmentImageView.image = Image.addAttachmentImage
        attachmentImageView.contentMode = .center
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        if viewModelBankTransfer.performValidation() {
            if !imageMatchWithPlus() {
                self.viewModelBankTransfer.attachmentImage = UIImageJPEGRepresentation(attachmentImageView.image!, 1.0)
                self.requestForBankTransfer()
            } else {
                // no image found on image view
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.Empty.attachmentImage.localized(), handler: { _ in
                })
            }
        } else {
            self.showAlertWith(title: AlertTitle.error.localized(), message: viewModelBankTransfer.rule.message, handler: { _ in
            })
        }
    }
    
    @objc func actionDoneButton() {
        self.view.endEditing(true)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = SystemConstant.dateFormatterPattern
        lastSelectedDate = sender.date
        transferDateField.text = dateFormatter.string(from: sender.date)
        self.viewModelBankTransfer.transferDate = transferDateField.text!
    }
    
    func showAlertWith(title: String?, message: String?, handler: ((_ action: UIAlertAction) -> Void)?) {
        if let title = title, let message = message {
            let alertView = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: AlertButton.okay.localized(), style: .cancel, handler: handler)
            alertView.addAction(okButton)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BankTransferViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField ==  transferDateField {
            setDatePicker(textField: textField)
            
        } else if textField == transferMethodField {
            setPickerView(textField: textField, tagValue: PickerTag.transferMethod.rawValue)
            
        } /* else if textField == bankRecipientField {
            setPickerView(textField: textField, tagValue: PickerTag.bankRecipient.rawValue)
        }*/
        return true
    }
}

// MARK: - Delegates
extension BankTransferViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

// MARK: - Picker View Datasource and Delegates
extension BankTransferViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
      /*  case PickerTag.bankRecipient.rawValue:
            guard let bankRecipientArray = DataStorage.instance.bankRecipient else {
                return 0
            }
            return bankRecipientArray.count */
            
        case PickerTag.transferMethod.rawValue:
            guard let bankTransferArray = DataStorage.instance.bankTransferMethod else {
                return 0
            }
            return bankTransferArray.count
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
      /*  case PickerTag.bankRecipient.rawValue:
            guard let bankRecipientArray =  DataStorage.instance.bankRecipient else {
                return ""
            }
            return bankRecipientArray[row].label */
            
        case PickerTag.transferMethod.rawValue:
            guard let bankTransferArray =  DataStorage.instance.bankTransferMethod else {
                return ""
            }
            return bankTransferArray[row].label
            
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
      /*  case PickerTag.bankRecipient.rawValue:
            guard let bankRecipientArray =  DataStorage.instance.bankRecipient else {
                return
            }
            self.bankRecipientField.text =  bankRecipientArray[row].value
            self.viewModelBankTransfer.bankRecipient = bankRecipientField.text! */
            
        case PickerTag.transferMethod.rawValue:
            
            guard let bankTransferArray =  DataStorage.instance.bankTransferMethod else {
                return
            }
            self.transferMethodField.text = bankTransferArray[row].value
            self.viewModelBankTransfer.transferMethod = transferMethodField.text!
            
        default:
            return
        }
    }
}
