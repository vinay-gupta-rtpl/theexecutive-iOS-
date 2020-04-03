//
//  OrderStatusViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 31/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

enum OrderStatus {
    case success
    case cancel
    case fail
    case none
}

class OrderStatusViewController: DelamiViewController {
    @IBOutlet weak var orderStatusImageView: UIImageView!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderStatusMessage: UILabel!
    @IBOutlet weak var continueShoppingOrViewOrderButton: UIButton!
    
    var orderStatus: OrderStatus = .none
    var orderId: String?
    var orderInfo: OrderInfoModel?
    var checkoutViewModel = CheckoutViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        
        if let myOrderID = orderId {
            requestForOrderDetail(orderId: myOrderID)
        } else {
            debugPrint("Order id is not available.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestForOrderDetail(orderId: String) {
        Loader.shared.showLoading()
        CheckoutViewModel().getOrderDetails(orderId: orderId, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            if let result = response as? OrderInfoModel {
                
                // API call for order comment so can differentiate orders from mobile end and web end....
                self?.checkoutViewModel.addOrderCommentWithSpecificOrder(orderId: orderId, status: result.orderStatus ?? "", success: { _ in
                    print("API for comment order API called...")
                }, failure: { _ in
                    print("error")
                })
               
                self?.orderInfo = result
                if let status = result.orderStatusCode, status == "canceled" {
                    self?.orderStatus = .cancel
                }
                self?.configureUI()
                
            } else {
                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertFailureMessage.orderInfo.localized(), handler: { (_) in
                })
            }
            }, failure: { [weak self] (error) in
                Loader.shared.hideLoading()
                if let errorMessage = error?.userInfo["message"] as? String {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: errorMessage, handler: { (_) in
                    })
                } else {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: error?.localizedDescription ?? AlertFailureMessage.orderInfo.localized(), handler: { (_) in
                    })
                }
        })
    }
    
    func configureUI() {
        switch orderStatus {
        case .success:
            orderStatusImageView.image = #imageLiteral(resourceName: "order_success")
            orderStatusLabel.text = OrderStatusMessage.orderPleaced.localized()
            orderStatusMessage.numberOfLines = 0
            orderStatusMessage.textAlignment = .center
            orderStatusMessage.attributedText = getAttributedOrderMessage(statusMessage: OrderStatusMessage.ThanksForOrder.localized())
            continueShoppingOrViewOrderButton.setTitle(OrderButtonTitle.viewOrder.uppercased().localized(), for: .normal)
            
        case .cancel:
            orderStatusImageView.image = #imageLiteral(resourceName: "order_cancel")
            orderStatusLabel.text = OrderStatusMessage.orderCancelled.localized()
            orderStatusMessage.numberOfLines = 0
            orderStatusMessage.textAlignment = .center
            orderStatusMessage.attributedText = getAttributedOrderMessage(statusMessage: OrderStatusMessage.orderCancelledConfirmed.localized())
            continueShoppingOrViewOrderButton.setTitle(OrderButtonTitle.continueShopping.localized().uppercased().localized(), for: .normal)
            
        case .fail:
            orderStatusImageView.image = #imageLiteral(resourceName: "Promo_error")
            orderStatusLabel.text = OrderStatusMessage.orderFailed.localized()
            orderStatusMessage.numberOfLines = 0
            orderStatusMessage.textAlignment = .center
            orderStatusMessage.attributedText = getAttributedOrderMessage(statusMessage: OrderStatusMessage.orderFailedConfirmed.localized())
            continueShoppingOrViewOrderButton.setTitle(OrderButtonTitle.continueShopping.localized().uppercased().localized(), for: .normal)
            
        default:
            break
        }
    }
    
    func getAttributedOrderMessage(statusMessage: String) -> NSMutableAttributedString {
        let orderNumberMessage = ConstantString.orderNo.localized() + (orderInfo?.orderId ?? "")
        var virtualAccountNumberMessage = ""
        if let accountNumber = orderInfo?.virtualAccountNumber {
            virtualAccountNumberMessage = "\(OrderStatusMessage.bankAccountBCA.localized()): BCA" + "\n" + OrderStatusMessage.virtualAccountNumber.localized() + ": " + accountNumber
        }
        
        var finalString = orderNumberMessage + "\n"
        if orderStatus == .success {
            finalString += virtualAccountNumberMessage + (virtualAccountNumberMessage.isEmpty ? "\n" : "\n\n") + statusMessage
            finalString += SystemConstant.newLine + OrderStatusMessage.receiveOrderConfirmation.localized()
        } else {
            finalString += statusMessage
        }
        
        let finalAttributedString = NSMutableAttributedString(string: finalString)
        finalAttributedString.addAttribute(NSAttributedStringKey.font, value: FontUtility.regularFontWithSize(size: 14.0), range: NSRange(location: 0, length: finalString.count))
        
        if let messageRange = finalString.range(of: orderNumberMessage)?.nsRange {
            finalAttributedString.addAttribute(NSAttributedStringKey.font, value: FontUtility.mediumFontWithSize(size: 14.0), range: messageRange)
        }
        
        if let messageRange = finalString.range(of: virtualAccountNumberMessage)?.nsRange, !virtualAccountNumberMessage.isEmpty {
            finalAttributedString.addAttribute(NSAttributedStringKey.font, value: FontUtility.mediumFontWithSize(size: 14.0), range: messageRange)
        }
        
        return finalAttributedString
    }
    
    @IBAction func clickedContinueShoppingOrViewOrder(_ sender: UIButton) {
        if orderStatus == .success {
            guard let detailVC = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.orderDetail) as? OrderDetailViewController else { return }
            detailVC.orderNo = "\(orderInfo?.orderId ?? "")"
            detailVC.comingFrom = "orderSuccess"
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            if let rootVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.rootViewController) as? DelamiTabBarController {
                appDelegate.window?.rootViewController = rootVC
            }
        }
    }
}
