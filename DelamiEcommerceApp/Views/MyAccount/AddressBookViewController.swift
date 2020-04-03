//
//  AddressBookViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

enum AddressBookPreviousScreen {
    case myAccount
    case checkout
}

protocol CheckoutAddressCall: class {
    func returnFromSelectingAddress(selectedAddressID: Int64)
}

class AddressBookViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var addressBookTableView: UITableView!
    
    // MARK: - Variables
    var informationModel: MyInformationModel?
    var viewModelAddressBook = AddressBookViewModel()
    
    // getting values from previous screen
    var previousScreen: AddressBookPreviousScreen = .myAccount
    var selectedAddressID: Int64 = 0
    weak var delegate: CheckoutAddressCall?
    
    // MARK: - API call
    func requestForGetMyInformation() {
        self.view.endEditing(true)
        viewModelAddressBook.requestForMyInfo(success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let data = response as? MyInformationModel {
                self?.informationModel = data
                self?.addressBookTableView.reloadData()
            }
            }, failure: { _ in
               Loader.shared.hideLoading()
        })
    }
    
    func requestForChangeAddress(address: inout InfoAddress, changeType: AddressChangeType) {
        Loader.shared.showLoading()
        self.view.endEditing(true)
        let selectedAddress = address
        viewModelAddressBook.requestForChangeAddress(address: &address, changeType: changeType, success: { [weak self] (response) in
            if let infoModel = response as? MyInformationModel {
                self?.informationModel = infoModel
                if self?.previousScreen == .checkout && self?.selectedAddressID == selectedAddress.addressId {
                    self?.selectedAddressID = infoModel.addresses?.filter({ $0.defaultShipping == true }).first?.addressId ?? 0
                }
                self?.addressBookTableView.reloadData()
                Loader.shared.hideLoading()
            }
            
            }, failure: { [weak self] _ in
                self?.addressBookTableView.reloadData()
                Loader.shared.hideLoading()

        })
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        Loader.shared.showLoading()
        super.viewDidLoad()
        if self.informationModel != nil {
          addressBookTableView.reloadData()
        } else {
            requestForGetMyInformation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestForGetMyInformation()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavigationTitle.addressBook.localized()
        addBackBtn(imageName: Image.back)
        addNewAddressBtn()
    }
    
    override func actionBackButton() {
        self.view.endEditing(true)
        delegate?.returnFromSelectingAddress(selectedAddressID: selectedAddressID)
        self.navigationController?.popViewController(animated: true)
    }
    
    func addNewAddressBtn() {
        let rightBarBtn = UIButton()
        rightBarBtn.setImage(#imageLiteral(resourceName: "add_1x"), for: .normal)
        rightBarBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightBarBtn.setTitleColor(.black, for: .normal)
        rightBarBtn.addTarget(self, action: #selector(actionAddNewAddress), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarBtn)
    }
    
    @objc func actionAddNewAddress() {
        let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.addAddress) as? AddAddressViewController
        viewController?.comingFromScreen = ComingFromScreen.addAddress.rawValue
        self.navigationController?.pushViewController(viewController!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AddressBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.informationModel?.addresses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.AddressBook.cell) as? AddressBookTableViewCell
        cell?.selectionStyle = .none
        if let addressesArray = self.informationModel?.addresses {
            cell?.setUpCell(addressInfo: addressesArray[indexPath.row], atIndex: indexPath.row)
        }
        
        if previousScreen == .checkout {
            cell?.setAsDefaultButton.superview?.layer.borderWidth = 0.0
            if self.informationModel?.addresses?[indexPath.row].addressId == selectedAddressID {
                cell?.setAsDefaultButton.superview?.layer.borderWidth = 1.0
                cell?.setAsDefaultButton.superview?.layer.borderColor = UIColor.darkGray.cgColor
            }
        }
        cell?.idAddressBookDelegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if previousScreen == .checkout {
            selectedAddressID = self.informationModel?.addresses?[indexPath.row].addressId ?? 0
            addressBookTableView.reloadData()
            actionBackButton()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
}

extension AddressBookViewController: AddressBookCellProtocols {
    func showAlert() {
        self.showAlertWith(title: AlertTitle.error.localized(), message: AlertMessage.defaultAddressDelete.localized(), handler: { _ in
            
        })
    }
    
    func removeAddress(atIndex index: Int) {
        guard var removedAddress = self.informationModel?.addresses![index] else {
            return
        }
        self.showAlertWithTwoButton(title: AlertTitle.none, message: AlertMessage.sureToDeleteShippingAddress.localized(), okayHandler: { _ in
            // Make remove address
            self.requestForChangeAddress(address: &removedAddress, changeType: AddressChangeType(rawValue: AddressChangeType.removeAddress.rawValue)!)
        }, cancelHandler: { _ in
            
        })
    }
    
    func editAddress(atIndex index: Int) {
        guard let editableAddress = self.informationModel?.addresses![index] else {
            return
        }
        // Move to add address Screen
        let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.addAddress) as? AddAddressViewController
        viewController?.informationModel = editableAddress
        viewController?.comingFromScreen = ComingFromScreen.editAddress.rawValue
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func setDefaultAddress(atIndex index: Int) {
        guard var makeDefaultAddress = self.informationModel?.addresses![index] else {
            return
        }
        
        // Make default address
        requestForChangeAddress(address: &makeDefaultAddress, changeType: AddressChangeType(rawValue: AddressChangeType.makeDefaultAddress.rawValue)!)
    }
}
