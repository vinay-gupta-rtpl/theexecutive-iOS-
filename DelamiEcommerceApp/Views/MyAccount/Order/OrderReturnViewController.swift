//
//  OrderReturnViewController.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/15/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class OrderReturnViewController: DelamiViewController, ReturnOrderCall {
    //    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var orderDetailModel = OrderDetailModel()
    var orderNo = ""
    
    func getData() {
        Loader.shared.showLoading()
        tableView.isHidden = false
        orderDetailModel.getOrderDetail(orderID: orderNo, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let responseArray = response as? OrderDetailModel {
                self?.tableView.isHidden = false
                self?.orderDetailModel = responseArray
                if let orderNo = self?.orderNo {
                    self?.orderNumberLabel.text = ConstantString.orderNo.localized() + orderNo
                }
                self?.tableView.reloadData()
                //                self?.setData()
            }
            }, failure: { [weak self] (error) in
                self?.tableView.isHidden = false
                Loader.shared.hideLoading()
                self?.showAlertWith(title: AlertTitle.alert.localized(), message: "\(error?.localizedDescription ?? "")", handler: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavTitles.returns.localized()
        //        returnToView.layer.cornerRadius = 5.0
        //        returnFromView.layer.cornerRadius = 5.0
        addBackBtn(imageName: Image.back)
    }
    
    //    func setData() {
    //        if let shippingAddress = orderDetailModel.extensionAttributes?.formattedShippingAddress {
    //            nameFromLabel.text = shippingAddress.firstname + " " + shippingAddress.lastname
    //            emailLabel.text = orderDetailModel.email
    //            setUpAddress(addressInfo: shippingAddress)
    //            mobileNoFromLabel.text = shippingAddress.telephone
    //        }
    //
    //        if let returnAddress = orderDetailModel.extensionAttributes?.returnToAddress {
    //            nameToLabel.text = returnAddress.returnToName
    //            addressToLabel.text = returnAddress.returnToAddress
    //            mobileNoFromLabel.text = returnAddress.returnToContact
    //        }
    //    }
    
    //    func setUpAddress(addressInfo: InfoAddress) {
    //        var streetAddress: String = ""
    //        if let streetCount = addressInfo.street?.count, streetCount > 1 {
    //            streetAddress = (addressInfo.street?.first)! + " " + (addressInfo.street?.last)! + ""
    //        } else {
    //            streetAddress = (addressInfo.street?.first)! + " "
    //        }
    //        if let regionName = addressInfo.region?.regionName {
    //            streetAddress += " " + regionName
    //        }
    //        if let cityName = addressInfo.city {
    //            streetAddress += " " + cityName
    //        }
    //        addressFromLabel.text = streetAddress + " " + addressInfo.postcode + ", " + SystemConstant.defaultCountry
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func orderReturnAction(selectedMode: String) {
        Loader.shared.showLoading()
        let selectedItemArray = orderDetailModel.items?.filter { $0.isSelected == true }
        let selectedArrayContainReason = selectedItemArray?.filter { $0.reason == "" }
        let noReason = selectedArrayContainReason != nil && !(selectedArrayContainReason?.isEmpty ?? true)
        let isReturn: Bool = selectedItemArray != nil && !(selectedItemArray?.isEmpty ?? true)
        if isReturn {
            if !noReason {
                orderDetailModel.doReturn(orderDetailModel: orderDetailModel, orderNo: orderNo, selectedMode: selectedMode, success: { [weak self] _ in
                    Loader.shared.hideLoading()
                    self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertMessage.returnConfirm.localized(), handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    })
                    }, failure: { [weak self] error in
                        Loader.shared.hideLoading()
                        if let errorMsg = error?.userInfo["message"] {
                            self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                            })
                        } else {
                            self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                            })
                        }
                })
            } else {
                Loader.shared.hideLoading()
                self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.NoDataAvailable.reason.localized(), handler: nil)
            }
        } else {
            Loader.shared.hideLoading()
            self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.NoDataAvailable.item.localized(), handler: nil)
        }
    }
}

extension OrderReturnViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return orderDetailModel.items?.count ?? 0
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Order.itemDetail, for: indexPath) as? OrderReturnTableViewCell else {
                fatalError("Could not load OrderDetailTableViewCell")
            }
            if let itemModel = orderDetailModel.items?[indexPath.row] {
                cell.orderData = itemModel
                cell.setupCell(productModel: itemModel)
                //                cell.orderDetailModel = orderDetailModel
            }
            return cell
        case 1:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.address, for: indexPath) as? OrderReturnTableViewCell else {
                    fatalError("Could not load OrderDetailTableViewCell")
                }
                cell.orderDetailModel = orderDetailModel
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.returnMode, for: indexPath) as? ReturnModeTableViewCell else {
                    fatalError("Could not load OrderDetailTableViewCell")
                }
                cell.delegate = self
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 185
        case 1:
            return UITableViewAutomaticDimension
        default:
            return 150
        }    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Order.itemDetail, for: indexPath) as? OrderReturnTableViewCell else {
            fatalError("Could not load OrderDetailTableViewCell")
        }
        if let itemModel = orderDetailModel.items?[indexPath.row] {
            cell.orderData = itemModel
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
}
