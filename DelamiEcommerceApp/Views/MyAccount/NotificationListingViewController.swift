//
//  NotificationListingViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 09/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class NotificationListingViewController: DelamiViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var notificationListTableView: UITableView!
    @IBOutlet weak var emptyNotificationListingLabel: UILabel!
    
    // MARK: - Variables
    var notificationModel: [NotificationModel]?
    var comingFrom: String = ""
    
    // MARK: - API call
    func getNotificationListing() {
        Loader.shared.showLoading()
        NotificationModel().getNotificationList(success: { [weak self] (response) in
            Loader.shared.hideLoading()
            
            if let notificationArray = response as? [NotificationModel] {
                if notificationArray.isEmpty {
                    self?.emptyNotificationListingLabel.isHidden = false
                    self?.notificationListTableView.isHidden = true
                } else {
                    self?.emptyNotificationListingLabel.isHidden = true
                    self?.notificationListTableView.isHidden = false
                    self?.notificationModel = notificationArray
                    self?.notificationListTableView.reloadData()
                }
            }
            }, failure: { (error) in
                Loader.shared.hideLoading()
                // show msg according to API Response
                print(error.debugDescription)
        })
    }
    
    func updateReadStatus(notificationId: String) {
        NotificationModel().updateReadStatus(notificationId: notificationId, success: { [weak self] (response) in
            if let isUpadeRequired = response {
                if isUpadeRequired {
                    self?.getNotificationListing()
                }
            }
            }, failure: { (_) in
                // show msg according to API Response
        })
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emptyNotificationListingLabel.text = AlertValidation.Invalid.emptyNotificationList.localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getNotificationListing()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavigationTitle.notificationListing.localized()
        
        if self.comingFrom == ComingFromScreen.appDelegate.rawValue {
            addCrossBtn(imageName: Image.cross)
        } else {
            addBackBtn(imageName: Image.back)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Table View Delegate and DataSource
extension NotificationListingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.notificationModel?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Notification.cell) as? NotificationTableViewCell
        guard let notificationArray = self.notificationModel else {
            return UITableViewCell()
        }
        
        cell?.setUpMethod(notification: notificationArray[indexPath.row], index: indexPath.row)
        //        cell?.setUpMethod(index: indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let notification = self.notificationModel?[indexPath.row] else { return }
        
        // update read status
        if !notification.isMessageReaded {
            // API call
            self.updateReadStatus(notificationId: String(notification.notificationID))
        }
        
        switch notification.type {
        case NotificationType.category.rawValue:
            if let typeId = notification.typeId {
                
                let catModal = CatalogViewModel()
                catModal.categoryId = Int(typeId)
                
                guard let catalogController = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.catalog) as? CatalogViewController else {
                    return
                }
                catalogController.viewModel = catModal
                catalogController.screenType = ComingFromScreen.notificationListing.rawValue
                catalogController.navTitle = notification.redirectTitle ?? ""
                self.navigationController?.pushViewController(catalogController, animated: true)
            }
            
        case NotificationType.product.rawValue:
            if let skuID = notification.typeId {
                
                let viewModal = ProductDetailViewModel()
                viewModal.getProductDetails(skuId: skuID, success: { (response) in
                    guard let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController else {
                        return
                    }
                    viewController.productModel = response as? ProductModel
                    let nav = UINavigationController.init(rootViewController: viewController)
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }, failure: { (_) in
                    
                })
            }
            
        case NotificationType.order.rawValue:
            if let orderId = notification.typeId {
                
                guard let orderDetailVC = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.orderDetail) as? OrderDetailViewController else { return }
                
                orderDetailVC.orderNo = orderId
                orderDetailVC.comingFrom = ComingFromScreen.notificationListing.rawValue
                orderDetailVC.navTitle = notification.redirectTitle ?? ""
                self.navigationController?.pushViewController(orderDetailVC, animated: true)
            }
            
        case NotificationType.abendentCart.rawValue:
            guard let viewController = StoryBoard.myCart.instantiateViewController(withIdentifier: SBIdentifier.shoppingBag) as? ShoppingBagViewController else {
                return
            }
            viewController.comingFrom = ComingFromScreen.notificationListing.rawValue
            viewController.navTitle = notification.redirectTitle ?? ""
            let nav = UINavigationController.init(rootViewController: viewController)
            self.navigationController?.present(nav, animated: true, completion: nil)
            
        default :
            return
        }
    }
}
