//
//  CatalogViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 21/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import ZDCChat

enum RequestType {
    case search
    case filter
    case products
}
// MARK: - Protocols
protocol SortActionDelegate: class {
    func applySelectedSortOrder()
}

protocol FilterActionDelegate: class {
    func applySelectedFilters()
}

class CatalogViewController: DelamiViewController {
    // MARK: - Outlets and Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchField: BindingTextfield! {
        didSet {
            self.searchField.bind { self.viewModel.searchProduct.value = $0  }
        }
    }
    @IBOutlet weak var searchTransparentView: UIView!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var filterByButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var promotionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promotionView: UIView!
    @IBOutlet weak var promotionLabel: UILabel!
    
    var viewModel = CatalogViewModel()
    var viewModelPromotion = CatalogViewModel()
    var counter: Int = 1
    var searchString = ""
    var screenType: String?
    var navTitle: String?
    var firstTimer: Bool = false // for filter
    var isOrientationChange = false
    var isPromotionShow: Bool = true
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = viewModel.currentCategory.uppercased()
        self.tabBarController?.tabBar.isHidden = true
        
        addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"))
        addBackBtn(imageName: #imageLiteral(resourceName: "back"))
        
        // add observer because of iPad return key (down array to dismiss the keypad so when user downarrow key with hide keyboard set default functionalities of search bar and buttons.)
        NotificationCenter.default.removeObserver(self) // first deinitialize observer if any then asign.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideAction(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        searchField.text = searchString

        if screenType == ComingFromScreen.promotion.rawValue || screenType == ComingFromScreen.notificationListing.rawValue || screenType == ComingFromScreen.appDelegate.rawValue {
            self.navigationItem.title = navTitle ?? ""
            searchButton.setTitle("Search".localized().uppercased(), for: .normal)
            viewModel.requestForProductsForPromotionCategory()
        } else if  searchString != "" { // if any string available on searchField
            viewModel.searchProduct.value = searchString
            viewModel.requestForProducts(from: .search)
            searchButton.setTitle("Cancel".localized().uppercased(), for: .normal)
            
        } else {
            searchButton.setTitle("Search".localized().uppercased(), for: .normal)
            viewModel.requestForProducts(from: .products)
        }
        
        firstTimer = true
        viewModel.requestForSortByOptions()
        viewModel.requestForFilters()
        
        self.tabBarController?.tabBar.isHidden = true
        addBackBtn(imageName: #imageLiteral(resourceName: "back"))
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        viewModel.products.bind { (products) in
            Loader.shared.hideLoading()
            
            if self.isPromotionShow {
                self.setUpPromotionView()
                self.isPromotionShow = false
                
            } 
            
            if (products?.count ?? 0) == 0 {
                if self.viewModel.searchProduct.value != "" {
                    self.view.showNoDataAvailable(noDataText: AlertValidation.NoDataAvailable.search.localized() + " " + "\"\(self.viewModel.searchProduct.value)\"", noDataTextColor: ThemeColor.gray)
                } else {
                    self.view.showNoDataAvailable(noDataText: AlertValidation.NoDataAvailable.catalog.localized(), noDataTextColor: ThemeColor.gray)
                }
                self.collectionView.isHidden = true
            } else {
                self.removeNoDataAvailableMessage()
                self.collectionView.isHidden = false
                self.counter = 1
                self.collectionView.reloadData()
                
                if self.viewModel.pageNumber == 1 {
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                
                self.viewModel.isAppending = false
            }
            
            if self.viewModel.isFilterApplied {
                self.viewModel.isFilterApplied = true
            } else {
                self.viewModel.isFilterApplied = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCartCount()
        
        if screenType == ComingFromScreen.appDelegate.rawValue {
            addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isOrientationChange {
            isOrientationChange = false
            counter = 1
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        isOrientationChange = true
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Setup Methods
    func setUpPromotionView() {
        self.promotionView.isHidden = false
        
        if let promotionalMessage = AppConfigurationModel.sharedInstance.catalogListingPromotionMessage {
            self.promotionViewHeightConstraint.constant = 100.0
            self.promotionLabel.text = promotionalMessage
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { [weak self] _ in
            self?.promotionViewHeightConstraint.constant = 0.0
            self?.chatButton.isHidden = false
        })
    }
    
    func removeNoDataAvailableMessage() {
        // removing no data available label
        for noDataLabel in self.view.subviews where noDataLabel.tag == 1000 {
            noDataLabel.removeFromSuperview()
        }
    }
    
    func showSearchBarDefaultBehaviour() {
        searchTransparentView.isHidden = true
        searchButton.setTitle("Search".localized().uppercased(), for: .normal)
        searchField.text = ""
        self.view.endEditing(true)
    }
    
    // MARK: - Notification Observer
    @objc func keyboardWillHideAction(notification: Notification) {
        showSearchBarDefaultBehaviour()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    @IBAction func tapOnSearch(_ sender: UIButton) {
      showSearchBarDefaultBehaviour()
    }
    
    @IBAction func tapOnSortBy(_ sender: UIButton) {
        guard let sortByVC = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.sortBy) as? SortByViewController, viewModel.sortOptions?.count != 0 else {
            return
        }
        sortByVC.viewModel = viewModel
        sortByVC.delegate = self
        let sortByNav = UINavigationController(rootViewController: sortByVC)
        self.present(sortByNav, animated: true, completion: nil)
    }
    
    @IBAction func tapOnFilterBy(_ sender: UIButton) {
        
        guard let filterByVC = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.filterBy) as? FilterViewController, viewModel.filterData?.totalCount != 0 else {
            return
        }
        filterByVC.viewModel = viewModel
        filterByVC.delegate = self
        filterByVC.firstTimer = firstTimer
        let filterByNav = UINavigationController(rootViewController: filterByVC)
        self.present(filterByNav, animated: true, completion: nil)
    }
    
    @IBAction func tapOnPromotionView(_ sender: Any) {
        guard let link = AppConfigurationModel.sharedInstance.catalogListingPromotionURL, let linkURL = NSURL(string: link) as URL? else {
            return
        }
        
        if link != "" {
            if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
                webController.url = linkURL
                webController.navigationTitle = NavigationTitle.promotion.localized()
                let navigationController = UINavigationController(rootViewController: webController)
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tapOnSearchTransparentView(_ sender: UITapGestureRecognizer) {
        showSearchBarDefaultBehaviour()
    }
    
    // MARK: - Chat Functionality
    @IBAction func chatButtonAction(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = true
        
        // set logged in user info prefilled in the form
        ZDCChat.updateVisitor { user in
            user?.phone = ""
            user?.name = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userName ?? "")
            user?.email = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userEmail ?? "")
        }
        styleZendeskChatUI()
        ZDCChat.start(in: self.navigationController, withConfig: nil)
    }
    
    /**
     update zendesk chat UI components.
     
     - returns: No return value
     */
    func styleZendeskChatUI() {
        ZDCChatUI.appearance().backChatButtonImage = "back"
        // set offline agent view appearence
        ZDCLoadingErrorView.appearance().buttonFont = FontUtility.mediumFontWithSize(size: 17.0)
        ZDCLoadingErrorView.appearance().buttonBackgroundColor = .black
    }
}

// MARK: - Extention - CollectionView Layout
extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 7.5
        
        // here, 5 is for to show large tile at every 5th position in the catalog
        if indexPath.row == 5 * counter - 1 {
            counter += 1
            return CGSize(width: MainScreen.width - 30.0, height: ((MainScreen.width - 30.0) * (2.9 / 2)) + 78.0)
        } else {
            return CGSize(width: (MainScreen.width/2) - (padding + 15.0), height: ((MainScreen.width - 45.0)/2 * (2.9 / 2)) + 78.0)
        }
    }
}

// MARK: - Extention - CollectionView Datasource
extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.CheckoutAndOther.catalogProduct, for: indexPath) as? CatalogProductCell else {
            return CatalogProductCell()
        }
        cell.configure(viewModel: viewModel, indexPath: indexPath)
        return cell
    }
}

// MARK: - Extention - CollectionView Delegate
extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetailContainer) as? ProductDetailContainerViewController {
            viewController.catalogVM = viewModel
            viewController.selectedProductIndex = indexPath.row
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Extention -  ScrollView Delegate delegates
extension CatalogViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.checkAndLoadRemainingProducts(scrollView)
    }
}

// MARK: - Extention - Sort and Filter Delegate
extension CatalogViewController: SortActionDelegate {
    func applySelectedSortOrder() {
        viewModel.products.value?.removeAll()
        viewModel.pageNumber = 1
        removeNoDataAvailableMessage()
        viewModel.requestForProducts(from: .filter)
    }
}

extension CatalogViewController: FilterActionDelegate {
    func applySelectedFilters() {
        viewModel.isFilterApplied = true
        viewModel.products.value = nil
        viewModel.pageNumber = 1
        firstTimer = false
        removeNoDataAvailableMessage()
        viewModel.requestForProducts(from: .filter)
    }
}
// MARK: - Extention - Test field delegate
extension CatalogViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTransparentView.isHidden = false
        searchButton.setTitle("Cancel".localized().uppercased(), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchString = searchField.text ?? ""
        
        searchTransparentView.isHidden = true
        searchButton.setTitle("Search".localized().uppercased(), for: .normal)
        
        if searchField.text != "" {
            firstTimer = false
            viewModel.pageNumber = 1
            viewModel.searchProduct.value = searchField.text!
            removeNoDataAvailableMessage()
            viewModel.requestForProducts(from: .search)
            viewModel.requestForSortByOptions()
            viewModel.requestForFilters()
            
        } else {
            if searchField.text == "" {
                searchTransparentView.isHidden = true
                searchButton.setTitle("Search".localized().uppercased(), for: .normal)
                searchField.becomeFirstResponder() //
            }
        }
        self.view.endEditing(true)
        return true
    }
}
