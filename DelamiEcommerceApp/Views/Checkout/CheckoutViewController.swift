//
//  CheckoutViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class CheckoutViewController: DelamiViewController {
    @IBOutlet weak var checkoutTableView: UITableView!
    @IBOutlet weak var checkoutTotalView: UIView!
    @IBOutlet weak var checkoutTotalViewHeight: NSLayoutConstraint!
    @IBOutlet weak var upDownArrowButton: UIButton!
    @IBOutlet weak var totalTableView: UITableView!
    @IBOutlet weak var confirmOrderButton: UIButton!
    
    var shouldExpandedTotals: Bool = false
    var checkoutViewModel = CheckoutViewModel()
    var sectionTitleArray = [ConstantString.shippingAddress.localized(), "", ConstantString.shippingMethod.localized(), ConstantString.paymentMethod.localized(), ConstantString.totals]
    var selectedCartAddressAndShipping: CartAddressAndShippingModel?
    var subTotalWithDiscount: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NavigationTitle.checkout.localized()
        addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        
        styleAndConfigureCheckoutUI()
        
        // set previously selected address
        if let address = selectedCartAddressAndShipping?.address, let addressId = address.addressId {
            checkoutViewModel.checkoutModel.address = address
            checkoutViewModel.requestForShippingMethods(addressId: addressId)
        }
        
        // get initials data from APIs
        checkoutViewModel.fetchShoppingCartItems()
        checkoutViewModel.getCartTotalsInfo()
        checkoutViewModel.requestForGetMyInformation()
        
        if let userInfo = DataStorage.instance.userAddressModel {
            checkoutViewModel.addresses = userInfo.addresses ?? []
        }
        
        // binding method
        performViewModelBinding()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        checkoutTableView.reloadData()
    }
    
    // IBActions
    @IBAction func tapOnUpDownArrow(_ sender: UIButton) {
        shouldExpandedTotals = !shouldExpandedTotals
        sender.isSelected = !sender.isSelected
        
        UIView.animate(withDuration: 0.5) {
            self.checkoutTotalViewHeight.constant = self.shouldExpandedTotals ? 100.0 + CGFloat(self.checkoutViewModel.checkoutModel.totals.count * 40) : 150.0
        }
        
        totalTableView.reloadData()
        checkoutTableView.reloadData()
        checkoutTableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .top, animated: true)
    }
    
    @IBAction func confirmOrderButtonAction(_ sender: UIButton) {
        guard let selectedPayment = self.checkoutViewModel.checkoutModel.paymentMethods.filter({ $0.selected == true }).first else {
            self.showAlertWith(title: AlertTitle.none.localized(), message: AlertMessage.paymentMethodNotSelected.localized(), handler: { (_) in
            })
            return
        }
        
        Loader.shared.showLoading()
        
        checkoutViewModel.placeOrder(success: { [weak self] (orderID) in
            //Trigger a Event To initiate checkout.....
            let initialtedCheckout: [String: Any] = [
                API.FacebookEventDicKeys.orderId.rawValue: orderID ?? 0,
                API.FacebookEventDicKeys.cartAmmount.rawValue: self?.subTotalWithDiscount ?? 0.0]
//            AppEvents.logEvent(.init(FacebookEvents.initiateCheckout.rawValue), parameters: initialtedCheckout)
            AppEvents.logEvent(.initiatedCheckout, parameters: initialtedCheckout)
            
            self?.navigateToProceedOrder(orderID: orderID, selectedPayment: selectedPayment)
            }, failure: { (error) in
                Loader.shared.hideLoading()
                if let errorMessage = error?.userInfo["message"] as? String {
                    self.showAlertWith(title: AlertTitle.error.localized(), message: errorMessage, handler: { (_) in
                    })
                } else {
                    self.showAlertWith(title: AlertTitle.error.localized(), message: error?.localizedDescription ?? AlertFailureMessage.mailNotSent.localized(), handler: { (_) in
                    })
                }
        })
    }
    
    func navigateToProceedOrder(orderID: AnyObject?, selectedPayment: PaymentMethodModel) {
        let storeCode = UserDefaults.standard.getStoreCode() ?? ""
        let customerToken = UserDefaults.standard.getUserToken() ?? ""
        let redirectionUrl = Configuration().environment.baseURL + "apppayment" + "?store=\(storeCode)" + "&orderid=\(orderID!)" + "&token=\(customerToken)"
        
        if (selectedPayment.code ?? "") == "banktransfer" || (selectedPayment.code ?? "") == "cashondelivery" {
            self.navigateToOrderSuccess(status: .success, orderId: orderID as? String)
        } else {
            self.openSafariwithUrl(orderId: orderID as? String, url: redirectionUrl, title: selectedPayment.title)
        }
    }
    
    @objc func tapOnSection(_ button: UIButton?) {
        //                  checkoutTableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
        
        if let overlayButton = button, overlayButton.tag != checkoutViewModel.selectedSection {
            checkoutViewModel.selectedSection = overlayButton.tag
        } else {
            checkoutViewModel.selectedSection = 0
        }
        //        self.checkoutTableView.reloadSections(IndexSet(integersIn: 0..<(self.sectionTitleArray.count)), with: .automatic)
        self.checkoutTableView.reloadData()
        
        if button?.tag == 3 || button?.tag == 2 {
            checkoutTableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .top, animated: true)
        }
        
    }
    
    func styleAndConfigureCheckoutUI() {
        confirmOrderButton.backgroundColor = .black
        checkoutTotalViewHeight.constant = 160.0
        checkoutTableView.tableFooterView = UIView()
        totalTableView.tableFooterView = UIView()
        upDownArrowButton.isEnabled = false
    }
    
    func performViewModelBinding() {
        // binding: reload tableview on change in API data
        checkoutViewModel.shouldReload.bind { (_) in
            if self.checkoutViewModel.checkoutModel.address == nil && !self.checkoutViewModel.addresses.isEmpty {
                self.checkoutViewModel.checkoutModel.address = self.checkoutViewModel.addresses.filter({ $0.defaultShipping == true }).first
                if let addressId = self.checkoutViewModel.checkoutModel.address?.addressId {
                    self.checkoutViewModel.requestForShippingMethods(addressId: addressId)
                }
            }
            // reload checkout table view
            self.checkoutTableView.reloadData()
            
            // reload total view
            if self.checkoutViewModel.checkoutModel.totals.count > 0 {
                self.totalTableView.reloadData()
            }
        }
        
        // binding: check to enable confirm order button
        checkoutViewModel.shouldCheckForPayNow.bind { (_) in
            let shippingMethod = self.checkoutViewModel.checkoutModel.shippingMethods.filter({ $0.selected == true }).first
            let paymentMethod = self.checkoutViewModel.checkoutModel.paymentMethods.filter({ $0.selected == true }).first
            
            // reload checkout table view
            self.checkoutTableView.reloadData()
            
            if self.checkoutViewModel.checkoutModel.address != nil && shippingMethod != nil && paymentMethod != nil {
                self.confirmOrderButton.backgroundColor = kConfirmOrderButtonColor
            } else {
                self.confirmOrderButton.backgroundColor = .black
            }
        }
    }
    
    func openSafariwithUrl(orderId: String?, url: String, title: String?) {
        guard let linkURL = NSURL(string: url) as URL? else {
            return
        }
        
        if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
            webController.url = linkURL
            webController.navigationTitle = title
            webController.isFromPayment = true
            webController.orderId = orderId
            let navigationController = UINavigationController(rootViewController: webController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func navigateToOrderSuccess(status: OrderStatus, orderId: String?) {
        if let viewController = StoryBoard.checkout.instantiateViewController(withIdentifier: SBIdentifier.orderStatus) as? OrderStatusViewController {
            viewController.orderStatus = status
            viewController.orderId = orderId
            let navigationController = UINavigationController(rootViewController: viewController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension CheckoutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == checkoutTableView {
            return sectionTitleArray.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == checkoutTableView {
            switch section {
            case 0:
                return 1
            case 1:
                return checkoutViewModel.checkoutModel.items.count > 0 ? 1 : 0
            case 2..<4 where checkoutViewModel.selectedSection == section:
                return 1
            case 4:
                return 1
            default:
                return 0
            }
        } else {
            return shouldExpandedTotals ? checkoutViewModel.checkoutModel.totals.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == checkoutTableView {
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.address, for: indexPath) as? CheckoutAddressCell else {
                    return UITableViewCell()
                }
                
                if let address = checkoutViewModel.checkoutModel.address {
                    cell.configure(addressInfo: address)
                } else {
                    cell.nameLabel.isHidden = true
                    cell.mobileNumberLabel.isHidden = true
                    cell.addressLabel.text = "No address available. Please add address to checkout.".localized()
                    cell.addressLabel.textColor = UIColor.darkGray
                }
                return cell
                
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.checkoutItem, for: indexPath) as? CheckoutItemCell else {
                    return UITableViewCell()
                }
                cell.cartItems = checkoutViewModel.checkoutModel.items
                return cell
                
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.option, for: indexPath) as? CheckoutPaymentOptionsCell else {
                    return UITableViewCell()
                }
                
                cell.optionType = .shipping
                cell.viewModel = checkoutViewModel
                cell.configure()
                return cell
                
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.option, for: indexPath) as? CheckoutPaymentOptionsCell else {
                    return UITableViewCell()
                }
                cell.optionType = .payment
                cell.viewModel = checkoutViewModel
                cell.configure()
                return cell
                
            default:
                return UITableViewCell()
            }
        } else {
            if shouldExpandedTotals {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.doubleLabelTotal, for: indexPath)
                let total = checkoutViewModel.checkoutModel.totals[indexPath.row]
                if let totalLabel = cell.viewWithTag(101) as? UILabel {
                    totalLabel.text = total.title ?? ""
                    totalLabel.font = total.code == "grand_total" ? FontUtility.mediumFontWithSize(size: 16.0) : FontUtility.regularFontWithSize(size: 16.0)
                }
                
                if let totalValue = cell.viewWithTag(102) as? UILabel {
                    totalValue.text = SystemConstant.defaultCurrencyCode.localized() + " " + "\(total.value)".changeStringToINR()
                    totalValue.font = total.code == "grand_total" ? FontUtility.mediumFontWithSize(size: 16.0) : FontUtility.regularFontWithSize(size: 16.0)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.singleLabelTotal, for: indexPath)
                if let totalLabel = cell.viewWithTag(103) as? UILabel {
                    if let totalValue = checkoutViewModel.checkoutModel.totals.filter({ $0.code == "grand_total"}).first?.value {
                        totalLabel.isHidden = false
                        upDownArrowButton.isEnabled = true
                        totalLabel.text = ConstantString.total.localized() + " " + SystemConstant.defaultCurrencyCode.localized() + " " + "\(totalValue)".changeStringToINR()
                    } else {
                        totalLabel.isHidden = true
                        upDownArrowButton.isEnabled = false
                    }
                }
                return cell
            }
        }
    }
}

extension CheckoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == checkoutTableView {
            if section == 1 || section == 4 {
                return 0.0
            }
            return 60.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == checkoutTableView {
            switch indexPath.section {
            case 0:
                return UITableViewAutomaticDimension
            case 1:
                return checkoutViewModel.checkoutModel.items.count > 0 ? 300.0 : 0.0
            case 2 where checkoutViewModel.selectedSection == indexPath.section:
                return checkoutViewModel.checkoutModel.shippingMethods.count == 0 ? 0.0 : CGFloat(checkoutViewModel.checkoutModel.shippingMethods.count * 40) + 10.0
            case 3 where checkoutViewModel.selectedSection == indexPath.section:
                return checkoutViewModel.checkoutModel.paymentMethods.count == 0 ? 0.0 : CGFloat(checkoutViewModel.checkoutModel.paymentMethods.count * 40) + 10.0
            case 4:
                return checkoutTotalViewHeight.constant
            default:
                return 0
            }
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 1 else {
            return UIView()
        }
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: MainScreen.width, height: 60.0))
        headerView.backgroundColor = .white
        
        let overlayButton = UIButton(frame: headerView.bounds)
        overlayButton.tag = section
        overlayButton.addTarget(self, action: #selector(tapOnSection(_:)), for: .touchUpInside)
        headerView.addSubview(overlayButton)
        
        let headerTitle = UILabel(frame: CGRect(x: 20.0, y: 0.0, width: MainScreen.width - 60.0, height: 60.0))
        headerTitle.font = FontUtility.regularFontWithSize(size: 18.0)
        headerTitle.lineBreakMode = .byWordWrapping
        headerTitle.numberOfLines = 2
        headerTitle.adjustsFontSizeToFitWidth = true
        headerView.addSubview(headerTitle)
        
        var selectedShippingOrPayment = ""
        if section == 2 {
            selectedShippingOrPayment = checkoutViewModel.checkoutModel.shippingMethods.filter({ $0.selected }).first?.methodTitle ?? ""
        }
        
        if section == 3 {
            selectedShippingOrPayment = checkoutViewModel.checkoutModel.paymentMethods.filter({ $0.selected ?? false }).first?.title ?? ""
        }
        headerTitle.text = sectionTitleArray[section] + (selectedShippingOrPayment.isEmpty ? "" : " (\(selectedShippingOrPayment))")
        
        if section != 0 {
            let arrowButton = UIButton(frame: CGRect(x: MainScreen.width - 37.0, y: 22.5, width: 15.0, height: 15.0))
            arrowButton.imageView?.contentMode = .scaleAspectFit
            arrowButton.setImage(Image.forwardArrow, for: .normal)
            arrowButton.setImage(Image.downwardArrow, for: .selected)
            headerView.addSubview(arrowButton)
            
            if section == checkoutViewModel.selectedSection {
                arrowButton.isSelected = true
            } else {
                arrowButton.isSelected = false
            }
        }
        
        let seperatorView = UIView(frame: CGRect(x: 0.0, y: 59.5, width: MainScreen.width, height: 0.5))
        seperatorView.backgroundColor = .lightGray
        seperatorView.accessibilityIdentifier = "seperatorView"
        headerView.addSubview(seperatorView)
        
        if section == checkoutViewModel.selectedSection && section != 0 {
            seperatorView.isHidden = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == checkoutTableView && indexPath.section == 0 {
            if let viewController = StoryBoard.myAccountInfo.instantiateViewController(withIdentifier: SBIdentifier.addressBook) as? AddressBookViewController {
                var myInformationModel = MyInformationModel()
                myInformationModel.addresses = checkoutViewModel.addresses
                
                viewController.informationModel = myInformationModel
                viewController.previousScreen = .checkout
                viewController.selectedAddressID = checkoutViewModel.checkoutModel.address?.addressId ?? 0
                viewController.delegate = self
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
}

extension CheckoutViewController: CheckoutAddressCall {
    func returnFromSelectingAddress(selectedAddressID: Int64) {
        if let address = DataStorage.instance.userAddressModel?.addresses?.filter({ $0.addressId == selectedAddressID }).first, let addressId = address.addressId {
            if addressId != checkoutViewModel.checkoutModel.address?.addressId {
                checkoutViewModel.checkoutModel.shippingMethods.removeAll()
                checkoutViewModel.checkoutModel.paymentMethods.removeAll()
                
                // Disable conform & pay button
                self.confirmOrderButton.backgroundColor = .black
                
                // getting shipping methods
                self.checkoutViewModel.requestForShippingMethods(addressId: addressId)
            }
            checkoutViewModel.checkoutModel.address = address
            checkoutTableView.reloadData()
        }
    }
}
