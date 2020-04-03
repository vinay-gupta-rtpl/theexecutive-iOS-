//
//  HomeViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 12/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import SafariServices
import ZDCChat

let kCategoryListTableViewPadding: CGFloat = 15.0
let kCategoryLabelLeadingConstant: CGFloat = 20.0
let kCategoryCellHeightConstant: CGFloat = 44.0
let kCategoryTitleHeight: CGFloat = 30.0

class HomeViewController: DelamiViewController {
    // MARK: - Outlets and Variables
    @IBOutlet weak var categoryListTableView: CITreeView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: BindingTextfield!
    @IBOutlet weak var searchTransparentView: UIView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var chatButtonWidthConstant: NSLayoutConstraint!
    
    let viewModel = HomeDataViewModel()
    var categoryImageSizeDict: [Int: CGSize] = [:]
    var headers: [CollapsibleTableViewHeader?] = []
    var shouldReload: Bool = false
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Navigation bar
        addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 44))
        imageView.image = Image.homeLogo
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        // add observer because of iPad return key (down array to dismiss the keypad so when user downarrow key with hide keyboard set default functionalities of search bar and buttons.)
        NotificationCenter.default.removeObserver(self) // first deinitialize observer if any then asign.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideAction(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        configureUI()
        styleUI()
        
        registerObserverForNotification()
        
        if !DataStorage.instance.isLaunchedByNotificationCenter {
            Loader.shared.showLoading()
            DataStorage.instance.isLaunchedByNotificationCenter = false
        }
        
        // API calling
        viewModel.requestForPromotionList()
        viewModel.requestForCategoryList()
        
        // bind promotions and reload the table with its new value.
        viewModel.promotions.bind { _ in
            Loader.shared.hideLoading()
            self.categoryListTableView.reloadSections([0], with: .none)
        }
        
        // bind categories and reload the table with its new value.
        viewModel.categories.bind({ _ in
            Loader.shared.hideLoading()
            self.categoryListTableView.reloadData()
            self.categoryListTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.categoryListTableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryListTableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        searchField.text = ""
        searchButton.setTitle("Search".localized().uppercased(), for: .normal)
        searchTransparentView.isHidden = true
        updateCartCount()
        
        // getting logged in user info for zendesk chat
        if UserDefaults.instance.getUserToken() != nil && appDelegate.userName == nil && appDelegate.userEmail == nil {
            viewModel.getMyAccountInfo()
        }
        
        if shouldReload {
            viewModel.categories.value = viewModel.categories.value?.map({ (category: CategoryModel) -> CategoryModel in
                category.collapsed = false
                return category
            })
            shouldReload = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NotifyMaintenanceOrVersionUpdate"), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        categoryListTableView.reloadData()
        self.categoryListTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View Setup Methods
    func configureUI() {
        searchField.placeholder = ""
        
        categoryListTableView.commonInit()
        self.categoryListTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: categoryListTableView.frame.size.width, height: 0.01))
        categoryListTableView.treeViewDelegate = self
        categoryListTableView.treeViewDataSource = self
        categoryListTableView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    func styleUI() {
        categoryListTableView.collapseNoneSelectedRows = true
    }
    
    func registerObserverForNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NotifyMaintenanceOrVersionUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForAppVersionUpdate), name: NSNotification.Name(rawValue: "NotifyMaintenanceOrVersionUpdate"), object: nil)
    }
    
    // check the app for version update
    @objc func checkForAppVersionUpdate() {
        // Checking maintenance condition
        if let isInMaintenance = AppConfigurationModel.sharedInstance.maintenance, isInMaintenance == "1" {
            notifyMaintenanceMode()
            return
        }
        
        // check for version update
        if appDelegate.isVersionUpdateAvailable {
            Loader.shared.hideLoading()
            showAppUpdateAlert()
        }
    }
    
    func backToTop() {
        viewModel.categories.value = viewModel.categories.value?.map({ (category: CategoryModel) -> CategoryModel in
            category.collapsed = false
            return category
        })
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
    
    // MARK: - Button Actions
    @IBAction func searchButtonAction(_ sender: UIButton) {
        showSearchBarDefaultBehaviour()
    }
    
    @IBAction func tapOnSearchTransparentView(_ sender: UITapGestureRecognizer) {
        showSearchBarDefaultBehaviour()
    }
}

// MARK: - Extention

// Managing views when orientation changes
extension HomeViewController {
    func calculateImageHeight(_ image: UIImage?) -> CGFloat {
        if let imageSize = image?.size {
            guard imageSize.width > 0.0 else {
                return 0.0
            }
            let aspectRatio = imageSize.height / imageSize.width
            return MainScreen.width * aspectRatio
        } else {
            return 0.0
        }
    }
}

extension HomeViewController: CITreeViewDelegate {
    func treeViewHeaderHeight(_ treeView: CITreeView, section: Int) -> CGFloat {
        if section == 0 { // first section is for promotion slider
            return 0.0
        } else {
            if let category = viewModel.categories.value?[section - 1] {
                return calculateImageHeight(category.categoryImage) + kCategoryTitleHeight
            } else {
                return MainScreen.height - 180.0
            }
        }
    }
    
    func treeViewHeader(_ treeView: CITreeView, section: Int) -> UIView? {
        let header = CollapsibleTableViewHeader(reuseIdentifier: "header")
        header.frame.size = CGSize(width: MainScreen.width, height: treeViewHeaderHeight(treeView, section: section))
        header.section = section
        header.delegate = self
        
        if let category = viewModel.categories.value?[section - 1] {
            header.titleLabel.frame = CGRect(x: kCategoryListTableViewPadding, y: 0.0, width: MainScreen.width - (2 * kCategoryListTableViewPadding), height: kCategoryTitleHeight)
            header.titleLabel.text = category.name
            
            if let image = category.categoryImage {
                header.imageView.frame = CGRect(x: kCategoryListTableViewPadding, y: kCategoryTitleHeight, width: MainScreen.width - (2 * kCategoryListTableViewPadding), height: header.frame.height - kCategoryTitleHeight)
                header.imageView.image = image
            }
        }
        return header
    }
    
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode?) -> CGFloat {
        if indexPath.section == 0 {
            return ((MainScreen.width - 30.0) * 3/2) + 50.0
        } else {
            if let dataObj = treeViewNode?.item as? CategoryModel {
                if dataObj.isActive {
                    return kCategoryCellHeightConstant
                }
            }
        }
        return 0.0
    }
    
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode) {
        if let category = treeViewNode.item as? CategoryModel {
            if (category.shouldShowViewAll)! || category.children.isEmpty {
                if let catalogVC = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.catalog) as? CatalogViewController {
                    catalogVC.viewModel.categoryId = category.categoryId
                    catalogVC.viewModel.currentCategory = category.name ?? ""
                    self.navigationController?.pushViewController(catalogVC, animated: true)
                }
            } else {
                return
            }
        }
    }
    
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
}

extension HomeViewController: CITreeViewDataSource {
    func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode?) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = treeView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.promotion) as? PromotionCell else {
                return PromotionCell()
            }
            cell.promotionTextLabel.text = AppConfigurationModel.sharedInstance.homePromotionMessage ?? ""
            cell.promotionDelegate = self
            cell.configure(viewModel: viewModel)
            return cell
        } else {
            guard let cell = treeView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.category) as? CategoryCell else {
                return CategoryCell()
            }
            
            cell.arrowButton.imageView?.contentMode = .scaleAspectFit
            
            if let dataObj = treeViewNode?.item as? CategoryModel {
                if dataObj.isActive {
                    cell.categoryName.text = (dataObj.shouldShowViewAll)! ? ConstantString.viewAll.localized() : dataObj.name?.uppercased()
                }
                
                if dataObj.children.count > 0 {
                    cell.arrowButton.isHidden = false
                    cell.arrowButton.isSelected = treeView.selectedTreeViewNode == treeViewNode
                } else {
                    cell.arrowButton.isHidden = true
                }
            }
            
            cell.leadingCategoryNameConstraint.constant = kCategoryLabelLeadingConstant * CGFloat((treeViewNode?.level)! + 2)
            return cell
        }
    }
    
    func treeViewSelectedNodeChildren(for treeViewNodeItem: Any) -> [Any] {
        if let dataObj = treeViewNodeItem as? CategoryModel {
            return dataObj.children
        }
        return []
    }
    
    func treeViewDataArray(section: Int) -> [Any] {
        // section 0 is for promotion slider
        if section == 0 {
            return []
        } else {
            return viewModel.categories.value ?? []
        }
    }
    
    func treeViewSectionCount() -> Int {
        return 1 + (viewModel.categories.value?.count ?? 0)
    }
}

extension HomeViewController: PromotionCellTappedDelegate {
    func sendPromotionCellDataWithRow(promotionData: PromotionModel, rowNo: Int) {
        guard let promotionType = promotionData.type else {
            return
        }
        
        switch promotionType {
        case .category:
            let catModal = CatalogViewModel()
            catModal.categoryId = Int(promotionData.value!)
            catModal.pageNumber = 1
            
            if let searchController = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.catalog) as? CatalogViewController {
                searchController.viewModel = catModal
                searchController.screenType = ComingFromScreen.promotion.rawValue
                searchController.navTitle = promotionData.title
                self.view.endEditing(true)
                self.navigationController?.pushViewController(searchController, animated: true)
            }
            
        case .product:
            let viewModal = ProductDetailViewModel()
            viewModal.getProductDetails(skuId: promotionData.value!, success: { (response) in
                if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController {
                    viewController.productModel = response as? ProductModel
                    viewController.comingFrom = ComingFromScreen.promotion.rawValue
                    let nav = UINavigationController.init(rootViewController: viewController)
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }, failure: { (_) in
                
            })
            
        case .CMS:
            guard let linkURL = NSURL(string: promotionData.value!) as URL? else {
                return
            }
            if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
                webController.url = linkURL
                webController.navigationTitle = promotionData.title
                let navigationController = UINavigationController(rootViewController: webController)
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func openUrlForPromotion() {
        guard let link = AppConfigurationModel.sharedInstance.homePromotionURL, let linkURL = NSURL(string: link) as URL? else {
            return
        }
        
        if link != "" {
            if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
                webController.url = linkURL
                webController.navigationTitle = NavigationTitle.promotion
                let navigationController = UINavigationController(rootViewController: webController)
                self.navigationController?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}

extension HomeViewController: CollapsibleTableViewHeaderDelegate {
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !(viewModel.categories.value?[section - 1].collapsed ?? false)
        categoryListTableView.treeViewController.treeViewNodes.removeAll()
        
        viewModel.categories.value?[section - 1].collapsed = collapsed
        
        if let selectedSection = categoryListTableView.selectedSection, selectedSection != section {
            viewModel.categories.value?[selectedSection - 1].collapsed = false
        }
        categoryListTableView.reloadData()
        
        if categoryListTableView.selectedSection != section {
            let path = IndexPath(item: 0, section: section)
            categoryListTableView.scrollToRow(at: path, at: .top, animated: false)
        }
        categoryListTableView.selectedSection = section
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchController = StoryBoard.shop.instantiateViewController(withIdentifier: SBIdentifier.catalog) as? CatalogViewController
        if searchField.text == "" {
            showSearchBarDefaultBehaviour()
        } else {
            searchController?.searchString = searchField.text!
            self.navigationController?.pushViewController(searchController!, animated: true)
        }
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTransparentView.isHidden = false
        searchButton.setTitle("Cancel".localized().uppercased(), for: .normal)
    }
}
