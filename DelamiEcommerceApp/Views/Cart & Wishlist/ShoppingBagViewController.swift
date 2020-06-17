//
//  ShoppingBagViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 03/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class ShoppingBagViewController: DelamiViewController {
    // MARK: - Outlets
    /// total shopping bag item count
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var shoppingItemListTableView: UITableView!
    @IBOutlet weak var noItemAvailableLabel: UILabel!
    
    // MARK: - Variables
    var viewModelShoppingCart = ShoppingCartViewModel()
    var viewModelProductDetail = ProductDetailViewModel()
    var txtfld: UITextField?
    var comingFrom: String?
    var navTitle: String?
    
    // MARK: - API Call
    func requestForMoveItemBagToWishlist(itemId: Int64, itemName: String) {
        Loader.shared.showLoading()
        viewModelShoppingCart.moveItemFromCartToWishlist(itemId: itemId, success: { [weak self] (response) in
            Loader.shared.hideLoading()
            self?.showAlertWith(title: AlertTitle.success.localized(), message: response, handler: {_ in
            })
            }, failure: {
                Loader.shared.hideLoading()
                weak var weakSelf = self
                weakSelf?.showAlertWith(title: AlertTitle.error.localized(), message: weakSelf?.viewModelShoppingCart.apiError.message, handler: { _ in
                })
        })
    }
    
    func getCartTotal(userType: UserType, reloadTable: Bool = true) {
        viewModelShoppingCart.getCartTotal(userType: userType, success: { [weak self] (_) in
            if reloadTable {
                self?.reloadCartTable()
            } else {
                self?.shoppingItemListTableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .automatic)
            }
            }, failure: { [weak self] error in
                if let errorMsg = error?.userInfo["message"] {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                }
        })
    }
    
    func getAppliedPromoCode(userType: UserType) {
        viewModelShoppingCart.getAppliedPromoCode(userType: userType, success: { [weak self] (response) in
            if let promoCode = response as? String {
                self?.viewModelShoppingCart.promoCode = promoCode
                self?.reloadCartTable()
            }
            }, failure: { _ in
        })
    }
    
    func applyPromoCode(promoCode: String, userType: UserType) {
        Loader.shared.showLoading()
        viewModelShoppingCart.applyPromoCode(promoCode: promoCode, userType: userType, success: { [weak self] (isPromoCodeApplied) in
            Loader.shared.hideLoading()
            if isPromoCodeApplied {
                self?.viewModelShoppingCart.promoCode = promoCode // applied promo code save in viewmodel class object.
                self?.viewModelShoppingCart.wrongPromoApplied = false
                self?.getCartTotal(userType: userType, reloadTable: false)
                //                 self?.shoppingItemListTableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .automatic)
            }
            }, failure: { [weak self] (_) in // wrong promo code
                Loader.shared.hideLoading()
                self?.viewModelShoppingCart.promoCode = ""
                self?.viewModelShoppingCart.wrongPromoApplied = true
                self?.shoppingItemListTableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .automatic)
        })
    }
    
    func deleteAppliedPromoCode(userType: UserType) {
        Loader.shared.showLoading()
        viewModelShoppingCart.deleteAppliedPromoCode(userType: userType, success: { [weak self] (isPromoCodedeleted) in
            Loader.shared.hideLoading()
            if isPromoCodedeleted {
                self?.viewModelShoppingCart.promoCode = "" // No promo code now.
                self?.getCartTotal(userType: userType, reloadTable: false)
                // reload particular checkout section if there is any changes happen.  No need to reload whole cart table.
//                self?.shoppingItemListTableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .automatic)
            }
            }, failure: { [weak self] error in
                Loader.shared.hideLoading()
                if let errorMsg = error?.userInfo["message"] {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                }
        })
    }
    
    func updateCartItemQuantity(itemId: Int64, quoteId: String, quantity: Int, userType: UserType) {
        Loader.shared.showLoading()
        viewModelShoppingCart.updateCartItemQuantity(itemId: itemId, quoteId: quoteId, quantity: quantity, userType: userType, success: { [weak self] _  in
            //            Loader.shared.hideLoading()  Hide loading in get cart total API response so after loading list seems to get fluctuate immediately.
            self?.viewModelShoppingCart.fetchShoppingBagItemList(userType: userType, failure: { (_) in
            })
            }, failure: { [weak self] error in
                Loader.shared.hideLoading()
                if let errorMsg = error?.userInfo["message"] {
                    self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                    })
                }
        })
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if comingFrom == ComingFromScreen.notificationListing.rawValue {
            self.navigationItem.title = navTitle ?? NavigationTitle.shoppingBag.localized()
        } else {
            self.navigationItem.title = NavigationTitle.shoppingBag.localized()
        }
        
        addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        shoppingItemListTableView.register(UINib(nibName: CellIdentifier.CartAndWishlist.cell, bundle: nil), forCellReuseIdentifier: CellIdentifier.CartAndWishlist.cell)
        shoppingItemListTableView.tableFooterView = UIView()
        
        // binding
        viewModelShoppingCart.shoppingCartItems.bind { _ in
            if let cartItemsArray = self.viewModelShoppingCart.shoppingCartItems.value {
                if cartItemsArray.isEmpty {
                    self.noItemFound()
                } else {
                    Loader.shared.hideLoading()
                    // if more than 0 Item Found in cart table
                    self.noItemAvailableLabel.isHidden = true
                    self.shoppingItemListTableView.isHidden = false
                    self.itemCountLabel.isHidden = false
                    
                    var totalQty: Int64 = 0
                    for item in cartItemsArray {
                        totalQty += item.quantity
                    }
                    
                    let totalString = ConstantString.itemsInCart.localized()
                    if let number = Int(totalString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                        self.itemCountLabel.text = totalString.replacingOccurrences(of: String(number), with: String(totalQty))
                    }
                    
                    //                    self.itemCountLabel.text = ConstantString.total.localized() + " " + String(totalQty) + " " + ConstantString.itemsInCart.localized()
                    self.reloadCartTable()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Loader.shared.hideLoading()
        
        // first check is user is logged in or not
        let userType: UserType = UserDefaults.standard.getUserToken() != nil ? UserType.registeredUser : UserType.guest
        
        if userType == .guest && UserDefaults.standard.getGuestCartToken() == nil {
            self.noItemFound()
        } else {
            Loader.shared.showLoading()
            viewModelShoppingCart.fetchShoppingBagItemList(userType: userType, failure: { (error) in
                if let statusCode = error?.code, statusCode == 400 || statusCode == 404 {
                    DelamiTabBarViewModel().refreshCartToken(user: userType, completion: { [weak self] (isSucceed) in
                        if isSucceed {
                            self?.viewModelShoppingCart.fetchShoppingBagItemList(userType: userType, failure: { (_) in
                                self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                                })
                            })
                        } else {
                            self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                            })
                        }
                    })
                } else {
                    self.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                    })
                }
            })
            getAppliedPromoCode(userType: userType)
            viewModelShoppingCart.getCartAddressAndShipping()
        }
    }
    
    func navigateToLogin() {
        if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.login) as? LoginViewController {
            let navController = UINavigationController.init(rootViewController: viewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    func reloadCartTable() {
        self.shoppingItemListTableView.delegate = self
        self.shoppingItemListTableView.dataSource = self
        self.shoppingItemListTableView.reloadData()
    }
    
    func noItemFound() {
        Loader.shared.hideLoading()
        self.noItemAvailableLabel.isHidden = false
//        self.noItemAvailableLabel.text = AlertValidation.NoDataAvailable.cart.localized()
        
        if let storeCode = UserDefaults.instance.getStoreCode(), storeCode == "ID" {
            self.noItemAvailableLabel.text = "Tas Belanja anda kosong!"
        } else {
            self.noItemAvailableLabel.text = "Your Cart is empty!".localized()
        }
        
        self.shoppingItemListTableView.isHidden = true
        self.itemCountLabel.isHidden = true
    }
    
    func showAlertAndMoveToLogin(alertmsg: String) {
        self.showAlertWithTwoButton(title: "", message: alertmsg, okayHandler: { _ in
            self.navigateToLogin()
        }, cancelHandler: { _ in
            
        })
    }
    
    func getProductOptions(item: ShoppingBagModel, optionType: OptionType) -> String {
        return item.productOption?.productExtentionAttribute?.colorSizeConfigOption?.filter({($0.extensionAttributes?.colorSizeOptionLabel ?? "") == optionType.rawValue}).first?.extensionAttributes?.colorSizeOptionValue ?? ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableView DataSource
extension ShoppingBagViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // one for product cell and one for checkout cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let cartArray = viewModelShoppingCart.shoppingCartItems.value {
                self.shoppingItemListTableView.separatorStyle = cartArray.isEmpty ? .none : .singleLine
            }
            return viewModelShoppingCart.shoppingCartItems.value?.count ?? 0
        case 1:
            guard let count = viewModelShoppingCart.shoppingCartItems.value?.count else {
                return 0
            }
            return count > 0 ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CartAndWishlist.cell, for: indexPath) as? CartAndWishlistCell else {
                return UITableViewCell()
            }
            cell.tag = indexPath.row
            cell.productName.tag = indexPath.row
            cell.productImageView.tag = indexPath.row
            cell.shoppingBagCallDelegate = self
            cell.cellType = .shoppingBag
            cell.configureShoppingBagCell(shoppingBagItem: viewModelShoppingCart.shoppingCartItems.value?[indexPath.row])
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CartAndWishlist.checkoutCell, for: indexPath) as? ShoppingBagCheckoutCell else {
                return UITableViewCell()
            }
            cell.checkoutCallDelegate = self
            cell.setUpCell(viewModel: self.viewModelShoppingCart)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
}

// MARK: - TableView Delegate
extension ShoppingBagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ShoppingBagViewController: UITextFieldDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let textField = txtfld, textField.isFirstResponder {
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        txtfld = textField
        self.shoppingItemListTableView.contentOffset = CGPoint(x: 0, y: (abs(textField.convert(textField.frame.origin, from: shoppingItemListTableView).y)) - 150)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        //       When press return key of keypad bit scroll the table
        self.shoppingItemListTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
        return true
    }
}

// MARK: - Shopping Bag Delegate
extension ShoppingBagViewController: ShoppingBagCall {
    func tappedOnRemoveButton(index: Int?) {
        if let selectedIndex = index, let itemId = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].identifier {
            self.showAlertWithTwoButton(title: AlertTitle.none, message: AlertMessage.shoppingBagItemRemove.localized(), okayHandler: { _ in
                // first check is user is logged in or not
                let userType: UserType = UserDefaults.standard.getUserToken() != nil ? UserType.registeredUser : UserType.guest
                Loader.shared.showLoading()
                self.viewModelShoppingCart.removeShoppingBagItem(itemId: itemId, userType: userType)
            }, cancelHandler: { _ in
            })
        }
    }
    
    // Move Item from cart To wishlist
    func tappedOnMoveCartToWishlist(index: Int?) {
        if let selectedIndex = index, let itemId = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].identifier {
            
            // check if user is loggedIn or not
            if UserDefaults.standard.getUserToken() != nil {
                let name = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].name ?? ""
                self.requestForMoveItemBagToWishlist(itemId: itemId, itemName: name)
                
            } else {
                self.showAlertAndMoveToLogin(alertmsg: AlertValidation.Invalid.tapOnWishlist.localized())
            }
        }
    }
    
    func tappedOnUpdateQuantityButton(index: Int?, updateType: UpdateQuantityType?, quantity: Int64?) {
        // API call for update Items quantity in cart
        if let selectedIndex = index, let itemId = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].identifier, let quoteId = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].quoteId, let qty = quantity {
            
            if let stockQuantity = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex].productExtentionAttribute?.stockInfo?.quantity, qty > stockQuantity {
                self.showAlertWith(title: AlertTitle.none, message: AlertMessage.quantityUnavailable.localized(), handler: nil)
                return
            }
            let userType: UserType = UserDefaults.standard.getUserToken() != nil ? UserType.registeredUser : UserType.guest
            self.updateCartItemQuantity(itemId: Int64(itemId), quoteId: quoteId, quantity: Int(qty), userType: userType)
        }
    }
    
    func navigateToProductDetailPage(index: Int?) {
        if let selectedIndex = index, let item = self.viewModelShoppingCart.shoppingCartItems.value?[selectedIndex] {
            let skuId = item.productType == "configurable" ? (item.productExtentionAttribute?.configurableSKU ?? "") : item.skuId
            let viewModal = ProductDetailViewModel()
            viewModal.getProductDetails(skuId: skuId, success: { (response) in
                if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController {
                    viewController.productModel = response as? ProductModel
                    viewController.comingFrom = ComingFromScreen.shoppingBag.rawValue
                    let nav = UINavigationController.init(rootViewController: viewController)
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }, failure: { (_) in
                
            })
        }
    }
}

extension ShoppingBagViewController: CheckoutCall {
    func applyPromoCode(promoCode: String) {
        let userType: UserType = UserDefaults.standard.getUserToken() != nil ? UserType.registeredUser : UserType.guest
        let promo = promoCode.trimmingCharacters(in: .whitespaces)
        applyPromoCode(promoCode: promo, userType: userType)
    }
    
    func deletePromoCode() {
        let userType: UserType = UserDefaults.standard.getUserToken() != nil ? UserType.registeredUser : UserType.guest
        self.deleteAppliedPromoCode(userType: userType)
    }
    
    func checkoutActionCalled() {
        if UserDefaults.standard.getUserToken() != nil {
            if let cartItems = self.viewModelShoppingCart.shoppingCartItems.value {
                var notAbleToCheckout = false
                
                // check product is out of stock
                for cartItem in cartItems {
                    if let isInStock = cartItem.productExtentionAttribute?.stockInfo?.isInStock, let stockQuantity = cartItem.productExtentionAttribute?.stockInfo?.quantity {
                        if !isInStock || stockQuantity < cartItem.quantity {
                            /* If any product is out of stock or have quantity more than available stock quantity then this flag will set */
                            notAbleToCheckout = true
                            self.showAlertWith(title: AlertTitle.none, message: AlertMessage.outOfStockHandling.localized(), handler: {_ in
                            })
                            return
                        }
                    }
                }
                
                // check product quantity > available stock quantity
                if !notAbleToCheckout {
                    // Move to checkout screen
                    guard let checkoutVC = StoryBoard.checkout.instantiateViewController(withIdentifier: SBIdentifier.checkout) as? CheckoutViewController else {
                        return
                    }
                    checkoutVC.selectedCartAddressAndShipping = viewModelShoppingCart.cartAddressAndShippingModel
                    
                    if let grandTotal =  self.viewModelShoppingCart.cartTotals?.subtotalWithDiscount {
                        let price = String(grandTotal)
                        let cartTotal = price.changeStringToINR()
                        checkoutVC.subTotalWithDiscount = Double(cartTotal)
                    }
                    let checkoutNav = UINavigationController(rootViewController: checkoutVC)
                    self.present(checkoutNav, animated: true, completion: nil)
                }
            }
        } else { // Guest so have to login first
            showAlertAndMoveToLogin(alertmsg: AlertValidation.Invalid.tapOnCheckout.localized())
        }
    }
}
