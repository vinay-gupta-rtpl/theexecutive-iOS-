//
//  OrderDetailViewController.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/15/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class OrderDetailViewController: DelamiViewController {
    @IBOutlet weak var headerOverView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var grandTotalLabel: UILabel!
    @IBOutlet weak var shippingTotalLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var paymentIDLabel: UILabel!
    @IBOutlet weak var staticPaymentIDLabel: UILabel!
    var orderNo: String = ""
    var orderDetailModel = OrderDetailModel()
    var navTitle: String?
    var comingFrom: String? = ""

    func requestForOrderDetail() {
        Loader.shared.showLoading()
        orderDetailModel.getOrderDetail(orderID: orderNo, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let responseArray = response as? OrderDetailModel {
                self?.orderDetailModel = responseArray
                let address = self?.orderDetailModel.extensionAttributes?.formattedShippingAddress
//                guard let firstname = self?.orderDetailModel.firstName, let lastname = self?.orderDetailModel.lastName, let dateOfOrder = self?.orderDetailModel.date else {
//                    return
//                }
                
                guard let firstname = self?.orderDetailModel.extensionAttributes?.formattedShippingAddress?.firstname, let lastname = self?.orderDetailModel.extensionAttributes?.formattedShippingAddress?.lastname, let dateOfOrder = self?.orderDetailModel.date else {
                    return
                }
                
                self?.nameLabel.text = "\(firstname + " " + lastname)"
                self?.emailLabel.text = "\(self?.orderDetailModel.email ?? "")"
                self?.grandTotalLabel.attributedText = Utils().createPriceAttribueString(regularPrice: String(self?.orderDetailModel.grandTotal ?? 0), specialPrice: "")
                self?.shippingTotalLabel.attributedText = Utils().createPriceAttribueString(regularPrice: String(self?.orderDetailModel.shippingInclTax ?? 0), specialPrice: "")
                self?.subTotalLabel.attributedText = Utils().createPriceAttribueString(regularPrice: String(self?.orderDetailModel.subtotalInclTax ?? 0), specialPrice: "")

                self?.productCountLabel.text = "\(self?.orderDetailModel.totalOrderedQty ?? 1)"
                self?.dateLabel.text = self?.dateFormatter(date: dateOfOrder)
                self?.setUpAddress(addressInfo: address!)
                self?.paymentMethodLabel.text = "\(self?.orderDetailModel.extensionAttributes?.paymentMethod ?? "")"
                if self?.orderDetailModel.extensionAttributes?.virtualAccountNumber == "" || self?.orderDetailModel.extensionAttributes?.virtualAccountNumber == nil {
                    self?.staticPaymentIDLabel.isHidden = true
                    self?.paymentIDLabel.isHidden = true
                } else {
                    self?.paymentIDLabel.text = self?.orderDetailModel.extensionAttributes?.virtualAccountNumber
                }

                self?.tableView.reloadData()
                self?.tableView.isHidden = false
            }
        }, failure: { [weak self] (error) in
            Loader.shared.hideLoading()
            self?.showAlertWith(title: AlertTitle.alert.localized(), message: "\(error?.localizedDescription ?? "")", handler: nil)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        requestForOrderDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerOverView.layer.cornerRadius = 5.0

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = ConstantString.orderNo.uppercased().localized() + orderNo
        addBackBtn(imageName: Image.back)
        
        if self.comingFrom == ComingFromScreen.appDelegate.rawValue {
           addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        }
    }

    override func actionBackButton() {
        if comingFrom == ComingFromScreen.orderSuccess.rawValue {
            // Moving to Home viewcontroller
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            if let rootVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.rootViewController) as? DelamiTabBarController {
                appDelegate.window?.rootViewController = rootVC
            } else {
                (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
            }
        } else {
            super.actionBackButton()
        }
    }
    
    func dateFormatter(date: String) -> String {
        // 2018-05-15 13:39:05
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFromString = dateFormatter.date(from: date)      // "Nov 25, 2015, 4:31 AM" as NSDate

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = SystemConstant.dateFormatterPattern.localized() // "dd-MM-yyyy"

        return dateFormatter2.string(from: dateFromString!) // "Nov 25, 2015" as String
    }

    func setUpAddress(addressInfo: InfoAddress) {
        addressLabel.text = addressInfo.firstname + " " + addressInfo.lastname
        var streetAddress: String = ""
        var postalCode = ""
        if let streetCount = addressInfo.street?.count, streetCount > 1 {
            streetAddress = (addressInfo.street?.first)! + ", " + (addressInfo.street?.last)!
        } else {
            streetAddress = (addressInfo.street?.first)!
        }
        if let cityName = addressInfo.city {
            streetAddress += ", " + cityName
        }
        if let regionName = addressInfo.region?.regionName {
            streetAddress += " " + regionName
        }
        if let postCode = addressInfo.postcode {
            postalCode = " " + postCode
        }
        
        addressLabel.text = streetAddress + postalCode + ", " + SystemConstant.defaultCountry.localized()
    }

}

extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetailModel.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Order.detail.localized(), for: indexPath) as? OrderDetailTableViewCell else {
            fatalError("Could not load OrderDetailTableViewCell")
        }
        if let itemModel = orderDetailModel.items?[indexPath.row] {
            cell.setupCell(productModel: itemModel)
        }

        return cell
    }
}
