//
//  ProductDetailViewController.swift
//  ProjectDetailDemo
//
//  Created by Himani Sharma on 20/03/18.
//  Copyright © 2018 Himani Sharma. All rights reserved.
//

import UIKit
import SafariServices
import ZDCChat

protocol CartCountUpdate: class {
    func countUpdate(count: Int)
}

class ProductDetailViewController: DelamiViewController {
    // MARK: - Outlets
    @IBOutlet weak var productDetailTableView: UITableView!
    
    // MARK: - Variables
    var viewModel = ProductDetailViewModel()
    
    var pageIndex: Int?
    
    var comingFrom: String? = ""
    var productModel: ProductModel? // Configurable Product
    var simpleDataModel: [ProductDataModel] = [] // simple product
    
    var showDataModel: ProductDetailModel? // varible to render table data/ count
    var selectedProductModal: ProductDetailModel?
    
    var sizeContainer: SizeAndQuantityView?
    var quantityLabel: UILabel?
    var priceLabel: UILabel?
    var price: NSAttributedString? // price to show on "Add to bag" view
    
    var productColorAttributeID: Int?
    var productSizeAttributeID: Int?
    var quantityOrderded: Int = 0
    var selectedSizeBoxNo: Int = -1 // show first product's first size is seleceted
    
    var firstAppereance: Bool = true
    var itemSelected: Int = 0
    var popupType: PopupType = .sizeAndQuantity
    var navTitle: String?
    var zoomView: UIView?
    
    // MARK: - API Call
    func getChildrenOfProduct() {
        Loader.shared.showLoading()
        if let sku = self.productModel?.sku {
            viewModel.requestForChildrenOfProduct(skuId: sku, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                // Show first data of product data array( yellow, blue, pink) then show first yellow one.
                self?.showDataModel = self?.viewModel.productArray.first
                self?.productDetailTableView.delegate = self
                self?.productDetailTableView.dataSource = self
                self?.productDetailTableView.reloadData()
                self?.sizeContainer?.availableSizeCollectionView.reloadData()
                }, failure: { (_) in
                    Loader.shared.hideLoading()
            })
        }
    }
    
    func requestForStaticPageUrl() {
        Loader.shared.showLoading()
        viewModel.requestForStaticPageUrl(success: { [weak self] (data) in
            Loader.shared.hideLoading()
            if self?.viewModel.parentProductType == .simple {
                self?.simpleDataModel = self?.viewModel.setProductData(model: (self?.productModel)!, urlData: data!) ?? []
                self?.productDetailTableView.delegate = self
                self?.productDetailTableView.dataSource = self
                self?.productDetailTableView.reloadData()
            }
            }, failure: { (_) in
                Loader.shared.hideLoading()
        })
    }
    
    func addProductToWishList(colorOptionValue: Int?, sizeOptionValue: Int?) {
        //        if UserDefaults.standard.getUserToken() != nil {
        if let productSKU = self.productModel?.sku {
            Loader.shared.showLoading()
            viewModel.addProductToWishList(productSKU: productSKU, colorOptionID: productColorAttributeID, colorOptionsValue: colorOptionValue, sizeOptionID: productSizeAttributeID, sizeOptionValue: sizeOptionValue, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                self?.showAlertWith(title: AlertTitle.success.localized(), message: (self?.productModel?.name ?? ConstantString.product.localized()) + " " +  AlertSuccessMessage.Product.addedToWishlist.localized(), handler: {  _ in
                })
                }, failure: { (_) in
                    Loader.shared.hideLoading()
            })
        } else {
            debugPrint("product id is not available")
        }
    }
    
    func createGuestCart() {
        DelamiTabBarViewModel().requestForGuestCart(success: { [weak self] (_) in
            self?.addToCartGuest()  // add to cart API
            }, failure: { (_) in
        })
    }
    
    func addToCartGuest() {
        if viewModel.parentProductType == .simple {
            Loader.shared.showLoading()
            // for simple item no need to send color and size option values and its identifier values.
            viewModel.requestForAddToCartGuest(colorOptionID: 0, colorOptionsValue: "", sizeOptionID: 0, sizeOptionValue: 0, product: productModel!, quantity: quantityOrderded, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                self?.removeView()
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.Product.addedToBag.localized(), handler: { _ in })
                }, failure: { [weak self] (error) in
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
            guard validateProductForOrder() else {
                return
            }
            
            Loader.shared.showLoading()
            viewModel.requestForAddToCartGuest(colorOptionID: productColorAttributeID, colorOptionsValue: selectedProductModal?.colorAttribute?.colorCode, sizeOptionID: productSizeAttributeID, sizeOptionValue: Int(selectedProductModal?.sizeAttribute?.sizeCode ?? ""), product: productModel!, quantity: quantityOrderded, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                self?.removeView()
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.Product.addedToBag.localized(), handler: { _ in })
                }, failure: { [weak self] (error) in
                    Loader.shared.hideLoading()
                    if let errorMsg = error?.userInfo["message"] {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: (errorMsg as? String)!, handler: { _ in
                        })
                    } else {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                        })
                    }
            })
        }
    }
    
    func createRegisteredUserCart() {
        Loader.shared.showLoading()
        DelamiTabBarViewModel().requestForGetCartToken(success: { [weak self] (_) in
            Loader.shared.hideLoading()
            self?.addToCartUser()
            }, failure: { (_) in
                Loader.shared.hideLoading()
        })
    }
    
    func addToCartUser() {
        if viewModel.parentProductType == .simple {
            Loader.shared.showLoading()
            // for simple item no need to send color and size option values and its identifier values.
            viewModel.requestForAddToCartUser(colorOptionID: 0, colorOptionsValue: "", sizeOptionID: 0, sizeOptionValue: 0, product: productModel!, quantity: quantityOrderded, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                self?.removeView()
                DelamiTabBarViewModel().requestForGetCartToken(success: { (_) in
                }, failure: { (_) in
                })
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.Product.addedToBag.localized(), handler: { _ in
                })
                }, failure: { [weak self] (error) in
                    Loader.shared.hideLoading()
                    if let errorMsg = error?.userInfo["message"] as? String {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: errorMsg, handler: { _ in
                        })
                    } else {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                        })
                    }
            })
        } else {
            guard validateProductForOrder() else {
                return
            }
            Loader.shared.showLoading()
            viewModel.requestForAddToCartUser(colorOptionID: productColorAttributeID, colorOptionsValue: selectedProductModal?.colorAttribute?.colorCode, sizeOptionID: productSizeAttributeID, sizeOptionValue: Int(selectedProductModal?.sizeAttribute?.sizeCode ?? ""), product: productModel!, quantity: quantityOrderded, success: { [weak self] (_) in
                Loader.shared.hideLoading()
                self?.removeView()
                DelamiTabBarViewModel().requestForGetCartToken(success: { (_) in
                }, failure: { (_) in
                })
                self?.showAlertWith(title: AlertTitle.success.localized(), message: AlertSuccessMessage.Product.addedToBag.localized(), handler: { _ in })
                }, failure: { [weak self] (error) in
                    Loader.shared.hideLoading()
                    if let errorMsg = error?.userInfo["message"] as? String {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: errorMsg, handler: { _ in
                        })
                    } else {
                        self?.showAlertWith(title: AlertTitle.error.localized(), message: AlertValidation.somethingWentWrong.localized(), handler: { _ in
                        })
                    }
            })
        }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let productName = self.productModel?.name {
            self.navigationItem.title = productName.uppercased()
        }
        
        if self.comingFrom == ComingFromScreen.promotion.rawValue || self.comingFrom == ComingFromScreen.wishlist.rawValue || self.comingFrom == ComingFromScreen.shoppingBag.rawValue {
            self.tabBarController?.tabBar.isHidden = true
            addBackBtn(imageName: #imageLiteral(resourceName: "cancel"))
        } else if self.comingFrom == ComingFromScreen.appDelegate.rawValue {
            self.tabBarController?.tabBar.isHidden = true
            addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
            self.navigationItem.title = self.navTitle
        } else {
            addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        }
        
        viewModel.productModel = productModel
        viewModel.parentProductType = productModel?.type ?? .configurable
        
        if viewModel.from == .detailPage {
            viewModel.getProductDetails(skuId: (productModel?.sku)!, success: { [weak self] (response) in
                self?.productModel = response as? ProductModel
                self?.viewModel.productModel = response as? ProductModel
                self?.navigationItem.title = (response as? ProductModel)?.name
                self?.setDefaultDataForConfigurableProduct()
                
                }, failure: { (_) in
            })
        } else {
            if viewModel.parentProductType == .configurable {
                setDefaultDataForConfigurableProduct()
            } else {
                if productModel != nil {
                    requestForStaticPageUrl()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let addToBagView = self.sizeContainer, addToBagView.frame.origin.y == 0 {
            removeView()
        }
        
        if let imageViewer = zoomView {
            imageViewer.layoutViewOnOrientationChange()
        }
        
        productDetailTableView.reloadData()
    }
    
    override func actionBackButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCartCount()
        
        // getting logged in user info for zendesk chat
        if UserDefaults.instance.getUserToken() != nil && appDelegate.userName != nil && appDelegate.userEmail != nil {
            HomeDataViewModel().getMyAccountInfo()
        }
    }
    
    func validateProductForOrder() -> Bool {
        switch viewModel.productConfiguration {
        case .colorSize:
            if selectedProductModal?.colorAttribute == nil || selectedProductModal?.sizeAttribute == nil {
                return false
            }
        case .color:
            if selectedProductModal?.colorAttribute == nil {
                return false
            }
        case .size:
            if selectedProductModal?.sizeAttribute == nil {
                return false
            }
        default:
            selectedProductModal?.colorAttribute = nil
            selectedProductModal?.sizeAttribute = nil
            break
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigateToLogin() {
        if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.login) as? LoginViewController {
            let navController = UINavigationController.init(rootViewController: viewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Add to cart Action
    func setDefaultDataForConfigurableProduct() {
        if let productOption = self.productModel?.extensionAttributes?.productOptions {
            if let colorOptionID = productOption.filter({ ($0.name ?? "") == "Color" || ($0.name?.uppercased() ?? "") == "Warna".uppercased() }).first?.attributeId {
                productColorAttributeID = Int(colorOptionID)
                viewModel.productConfiguration = .color
            }
            if let sizeOptionID = productOption.filter({ ($0.name ?? "") == "Size" || ($0.name?.uppercased() ?? "") == "Ukuran".uppercased() }).first?.attributeId {
                productSizeAttributeID = Int(sizeOptionID)
                viewModel.productConfiguration = .size
            }
            if productColorAttributeID != nil && productSizeAttributeID != nil {
                viewModel.productConfiguration = .colorSize
            }
        }
        
        if let options = productModel?.extensionAttributes?.productOptions, options.count > 0 {
            for option in options {
                viewModel.requestForProductAttributeOption(option: option)
            }
            getChildrenOfProduct()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.sizeContainer?.availableSizeCollectionView.reloadData()
            })
        }
    }
    
    @objc func tapOnAddToBag() {
        quantityOrderded = productModel?.type == .simple || viewModel.productConfiguration == .color || viewModel.productConfiguration == .none ? 1 : 0
        selectedProductModal = nil
        self.selectedSizeBoxNo = -1
        
        if viewModel.productConfiguration == .color || viewModel.productConfiguration == .none {
            selectedProductModal = viewModel.productArray.first
        }
        
        let isSimpleProduct = viewModel.parentProductType == .simple
        popupType = isSimpleProduct ? .quantity : (viewModel.productConfiguration == .color || viewModel.productConfiguration == .none ? .quantity : .sizeAndQuantity)
        
        // add to bag option
        self.sizeContainer?.removeFromSuperview()
        self.sizeContainer = SizeAndQuantityView().initializeView(viewController: self, type: popupType, price: self.price!)
        self.sizeContainer?.addToBagPopupDelegate = self
        priceLabel = self.sizeContainer?.priceLabel
        UIApplication.shared.delegate?.window??.addSubview(sizeContainer!)
        
        UIView.animate(withDuration: 0.45, animations: {
            self.sizeContainer?.frame.origin.y = 0
        }, completion: nil)
    }
    
    /**
     update zendesk chat UI components.
     
     - returns: No return value
     */    
    @IBAction func chatAction(_ sender: Any) {
        // set logged in user info prefilled in the form
        ZDCChat.updateVisitor { user in
            user?.phone = ""
            user?.name = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userName ?? "")
            user?.email = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userEmail ?? "")
        }
        styleZendeskChatUI()
        ZDCChat.start(in: self.navigationController, withConfig: nil)
    }
}

// MARK: - Table View Delegates and Datasource
extension ProductDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if viewModel.from == .detailPage {
                return viewModel.dataSequenceModel?.count ?? 1
            }
            return (productModel?.type)! == .configurable ? viewModel.dataSequenceModel?.count ?? 1 : (simpleDataModel.count == 0 ? 1 : simpleDataModel.count)
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 80
        case 1:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if section == 0 {
            footerView.frame = CGRect(x: 16, y: 0, width: MainScreen.width - 32.0, height: 80)
            footerView.backgroundColor = .clear
            
            let view = UIView(frame: footerView.frame)
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            let addToBagButton: UIButton = UIButton(frame: CGRect(x: 10.0, y: 20.0, width: 120.0, height: 40.0))
            /*  if let storeCode = UserDefaults.instance.getStoreCode(), storeCode == "ID" {
             addToBagButton.frame.size = CGSize(width: 190.0, height: 40.0)
             } */
            
            addToBagButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            addToBagButton.setTitleColor(#colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), for: .normal)
            addToBagButton.layer.cornerRadius = 5.0
            addToBagButton.layer.borderWidth = 1.0
            addToBagButton.layer.borderColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            addToBagButton.setTitle(ButtonTitles.addToBag.uppercased().localized(), for: .normal)
            addToBagButton.titleLabel?.font = FontUtility.regularFontWithSize(size: 15.0)
            addToBagButton.addTarget(self, action: #selector(self.tapOnAddToBag), for: .touchUpInside)
            view.addSubview(addToBagButton)
            
            let priceLabel = UILabel(frame: CGRect(x: addToBagButton.frame.maxX + 10.0, y: 15.0, width: footerView.frame.width - (addToBagButton.frame.width + 18.0), height: 50))
            priceLabel.textColor = #colorLiteral(red: 0.1832801402, green: 0.1679286659, blue: 0.172621876, alpha: 1)
            priceLabel.numberOfLines = 2
            priceLabel.lineBreakMode = .byWordWrapping
            priceLabel.backgroundColor = .clear
            priceLabel.font = FontUtility.regularFontWithSize(size: 15.0)
            priceLabel.textAlignment = .right
            priceLabel.adjustsFontSizeToFitWidth = true
            view.addSubview(priceLabel)
            footerView.addSubview(view)
            
            var regularPrice: String = ""
            var specialPrice: String = ""
            
            if let product = productModel, product.type == .simple {
                regularPrice = product.price ?? ""
                specialPrice = product.customAttributes?.filter({$0.attributeCode == "special_price"}).first?.value ?? ""
            } else {
                regularPrice = selectedProductModal != nil ? selectedProductModal?.regularPrice ?? "" : (viewModel.productArray[itemSelected].regularPrice ?? "")
                specialPrice = selectedProductModal != nil ? selectedProductModal?.specialPrice ?? "" : (viewModel.productArray[itemSelected].specialPrice ?? "")
                
                //                regularPrice = productModel?.extensionAttributes?.regularPrice ?? ""
                //                specialPrice = productModel?.extensionAttributes?.specialPrice ?? ""
            }
            price = Utils().createPriceAttribueString(regularPrice: regularPrice, specialPrice: specialPrice)
            priceLabel.attributedText = price
            return footerView
        } else {
            price =  NSAttributedString.init(string: "")
            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var myData: ProductDataModel?
            if let product = productModel, product.type == .simple {
                myData = simpleDataModel[indexPath.row]
            } else {
                if let sequenceModel = viewModel.dataSequenceModel {
                    myData = sequenceModel[indexPath.row]
                }
            }
            
            guard let data = myData else {
                return UITableViewCell()
            }
            
            if data.type == .blank {
                let cell = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.image, for: indexPath) as? ProductImageTableViewCell)!
                cell.productImage.image = Image.placeholder
                cell.productImage.contentMode = .scaleAspectFit
                return cell
            }
            
            if data.type == .image {
                let cell = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.image, for: indexPath) as? ProductImageTableViewCell)!
                cell.setUpImageCell(productData: data)
                
                return cell
                
            } else if data.type == .description {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.description, for: indexPath) as? ProductDescriptionTableViewCell else {
                    return UITableViewCell()
                }
                cell.setUpCell(descriptionText: data.descriptionInfo!)
                
                return cell
                
            } else if data.type == .color {
                let cell = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.availableColors, for: indexPath) as? AvailableColorsTableViewCell)!
                cell.viewModel = viewModel
                cell.sendColletionIndexPath = self
                cell.isItFirstAppereance = firstAppereance
                cell.itemSelected = itemSelected
                cell.reloadData()
                
                return cell
                
            } else if data.type == .URLs {
                let cell = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.button, for: indexPath) as? ButtonTableViewCell)!
                cell.addToWishListButtonHandler = {
                    if UserDefaults.standard.getUserToken() != nil {
                        //                        if self.viewModel.parentProductType == .configurable {
                        //                            self.popupType = .size
                        //
                        //                            let sizeQuantityView = SizeAndQuantityView()
                        //                            self.sizeContainer = sizeQuantityView.initializeView(viewController: self, type: self.popupType, price: self.price!)
                        //                            sizeQuantityView.addToBagPopupDelegate = self
                        //                            self.priceLabel = sizeQuantityView.priceLabel
                        //                            UIApplication.shared.delegate?.window??.addSubview(self.sizeContainer)
                        //
                        //                            self.selectedSizeBoxNo = -1
                        //                            self.seletectedSizeModal = nil
                        //
                        //                            UIView.animate(withDuration: 0.45, animations: {
                        //                                self.sizeContainer.frame.origin.y = 0
                        //                            }, completion: nil)
                        //                        } else {
                        self.addProductToWishList(colorOptionValue: nil, sizeOptionValue: nil)
                        //                        }
                    } else {
                        self.showAlertWithTwoButton(title: "", message: AlertValidation.Invalid.loginToWishlist.localized(), okayHandler: { _ in
                            self.navigateToLogin()
                        }, cancelHandler: { _ in
                        })
                    }
                }
                
                guard let urls = data.urlLinks else {
                    return UITableViewCell()
                }
                cell.setUpCell(productStaticURL: urls)
                cell.idStaticButtonDelegate = self
                return cell
                
            } else {
                return UITableViewCell()
            }
            
        case 1:
            let cell = (tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProductDetail.wearWith, for: indexPath) as? WearWithTableViewCell)!
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        
        switch indexPath.section {
        case 0:
            if let product = productModel, product.type == .simple {
                guard simpleDataModel.count != 0 else {
                    return (((MainScreen.width - 32.0) * 2.9)/2) + 16.0
                }
            }
            
            guard let data = viewModel.dataSequenceModel?[indexPath.row] else {
                return (((MainScreen.width - 32.0) * 2.9)/2) + 16.0
            }
            
            if data.type == .blank {
                height = (((MainScreen.width - 32.0) * 2.9)/2) + 16.0
            } else if data.type == .description {
                height = UITableViewAutomaticDimension
            } else if  data.type == .color {
                height = 180.0 //self.productType?.rawValue == ProductType.configurable.rawValue ? 250 : 0
                
            } else if  data.type == .URLs {
                // ButtonTableViewCell
                return 425.0
                
            } else {
                height = (((MainScreen.width - 32.0) * 2.9)/2) + 16.0
            }
        case 1:
            // WearWithTableViewCell
            guard self.productModel != nil else {
                return 0.0
            }
            
            if let availableProduct = self.productModel?.productLinks {
                return availableProduct.count > 0 ? 380 : 0.0
            }
            
        default:
            height = 0.0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var myData: ProductDataModel?
        if let product = productModel, product.type == .simple {
            myData = simpleDataModel[indexPath.row]
        } else {
            myData = viewModel.dataSequenceModel?[indexPath.row]
        }
        
        guard let data = myData else {
            return
        }
        
        if data.type == .image {
            if let cell = tableView.cellForRow(at: indexPath) as? ProductImageTableViewCell {
                zoomView = UIView()
                zoomView?.funcZoomInOut(image: (cell.productImage?.image)!, crossImage: #imageLiteral(resourceName: "cancel"))
            }
        }
    }
}

// MARK: - Collection View delegate and datasource
extension ProductDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case Tagvalue.ProductDetailCollection.availableColor.rawValue:
            return 15
        case Tagvalue.ProductDetailCollection.wearWith.rawValue:
            guard self.productModel != nil else {
                return 0
            }
            if let productLinksArray = self.productModel?.productLinks {
                return productLinksArray.count
            } else {
                return 0
            }
            
        case Tagvalue.ProductDetailCollection.availableSize.rawValue:
            if viewModel.productConfiguration == .colorSize {
                if let colorCode = viewModel.colorOptions?[itemSelected].code {
                    return viewModel.groupedProducts[String(colorCode)]?.count ?? 0
                }
                return 0
            } else {
                return viewModel.productArray.count
            }
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == Tagvalue.ProductDetailCollection.availableSize.rawValue {
            return CGSize(width: 40.0, height: 80.0)
        } else if collectionView.tag == Tagvalue.ProductDetailCollection.wearWith.rawValue {
            return CGSize(width: 160.0, height: (160.0 * (2.9 / 2)) + 80.0)
        } else {
            return CGSize(width: 50.0, height: 50.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case Tagvalue.ProductDetailCollection.availableColor.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ProductDetail.colorCollection, for: indexPath)
            return cell
            
        case Tagvalue.ProductDetailCollection.wearWith.rawValue:
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ProductDetail.wearCollection, for: indexPath) as? WearWithCollectionViewCell)!
            
            guard self.productModel != nil else {
                return UICollectionViewCell()
            }
            guard self.productModel?.productLinks != nil else {
                return UICollectionViewCell()
            }
            
            cell.setupMethod(productLinkArray: (self.productModel?.productLinks)!, indexPath: indexPath)
            return cell
            
        case Tagvalue.ProductDetailCollection.availableSize.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ProductDetail.sizeCollection, for: indexPath)
            
            let sizeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
            sizeLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            sizeLabel.textAlignment = .center
            sizeLabel.font = FontUtility.regularFontWithSize(size: 14.0)
            sizeLabel.layer.borderWidth = 0.0
            
            var availableModel: ProductDetailModel?
            if viewModel.productConfiguration == .colorSize {
                if let colorCode = viewModel.colorOptions?[itemSelected].code {
                    availableModel = viewModel.groupedProducts[String(colorCode)]?[indexPath.row]
                }
            } else {
                availableModel = viewModel.productArray[indexPath.row]
            }
            
            // By Default the we are assuming all products are in stock so every cell shoukd be selecatble
            cell.isUserInteractionEnabled = true
            let boolValue = availableModel?.isInStock ?? false
            
            if !boolValue { // productModel?.extensionAttributes?.stockOptions?.isInStock {
                let outOfStockLabel = UILabel(frame: CGRect(x: 0, y: sizeLabel.frame.maxY + 5, width: 40.0, height: 40.0))
                outOfStockLabel.text = ConstantString.outOfStock.localized()
                outOfStockLabel.font = FontUtility.regularFontWithSize(size: 11.0)
                outOfStockLabel.adjustsFontSizeToFitWidth = true
                outOfStockLabel.textAlignment = .center
                outOfStockLabel.numberOfLines = 2
                outOfStockLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                cell.addSubview(outOfStockLabel)
                
                sizeLabel.textColor = popupType == .size ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                // As the product is out of stock  cell tap is disabled
                cell.isUserInteractionEnabled = popupType == .size ? true : false
            } else {
                
                sizeLabel.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                sizeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                for view in cell.subviews {
                    view.removeFromSuperview()
                }
            }
            
            if let sizeValue = availableModel?.sizeAttribute?.size {
                sizeLabel.text = sizeValue
            }
            
            if selectedSizeBoxNo != -1 && selectedSizeBoxNo == indexPath.row {
                sizeLabel.font = FontUtility.mediumFontWithSize(size: 14.0)
                sizeLabel.layer.borderWidth = 1.0
                sizeLabel.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            cell.addSubview(sizeLabel)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    //    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case Tagvalue.ProductDetailCollection.availableSize.rawValue:
            if viewModel.productConfiguration == .colorSize {
                if let colorCode = viewModel.colorOptions?[itemSelected].code {
                    selectedProductModal = viewModel.groupedProducts[String(colorCode)]?[indexPath.row]
                }
            } else {
                selectedProductModal = viewModel.productArray[indexPath.row]
            }
            quantityOrderded = 1
            quantityLabel?.text = "\(quantityOrderded)"
            
            let regularPrice = selectedProductModal != nil ? selectedProductModal?.regularPrice ?? "" : viewModel.productArray.first?.regularPrice ?? ""
            let specialPrice = selectedProductModal != nil ? selectedProductModal?.specialPrice ?? "" : viewModel.productArray.first?.specialPrice ?? ""
            priceLabel?.attributedText = Utils().createPriceAttribueString(regularPrice: regularPrice, specialPrice: specialPrice)
            
            selectedSizeBoxNo = indexPath.row
            collectionView.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            
        case Tagvalue.ProductDetailCollection.wearWith.rawValue:
            
            if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetailContainer) as? ProductDetailContainerViewController {
                viewController.catalogVM = createCatLogModel()
                viewController.from = .detailPage
                viewController.selectedProductIndex = indexPath.row
                self.navigationController?.present(viewController, animated: true, completion: nil)
            }
            
        default: break
        }
    }
    func createCatLogModel() -> CatalogViewModel {
        let catlogModal = CatalogViewModel()
        var productArrayModal: [ProductModel] = []
        
        for proLinkModel in (productModel?.productLinks!)! {
            let proModal = ProductModel()
            proModal.sku = proLinkModel.linkedProductSkuId
            productArrayModal.append(proModal)
        }
        
        catlogModal.products.value = productArrayModal
        
        return catlogModal
    }
}

// MARK: - Button Cell Protocols
extension ProductDetailViewController: ButtonCellProtocols {
    func openSafariwithUrl(url: String, title: String?) {
        guard let linkURL = NSURL(string: url) as URL? else {
            return
        }
        
        if let webController = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.webPageController) as? DelamiWebViewController {
            webController.url = linkURL
            webController.navigationTitle = title
            let navigationController = UINavigationController(rootViewController: webController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func shareLink() {
        let someText = productModel?.name ?? ""
        let baseURL = Configuration().environment.baseURL
        let productUrl = self.productModel?.customAttributes?.filter({ $0.attributeCode == "url_key" }).first?.value
        if let url = productUrl {
            let objectsToShare = baseURL + url + ".html"
            let sharedObjects: [AnyObject] = [objectsToShare as AnyObject, someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.mail]
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            return
        }
    }
    
    func openChat() {
        self.tabBarController?.tabBar.isHidden = true
        
        ZDCChat.updateVisitor { user in
            user?.phone = ""
            user?.name = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userName ?? "")
            user?.email = UserDefaults.standard.getUserToken() == nil ? "" : (appDelegate.userEmail ?? "")
        }
        styleZendeskChatUI()
        ZDCChat.start(in: self.navigationController, withConfig: nil)
    }
    
    func styleZendeskChatUI() {
        ZDCChatUI.appearance().backChatButtonImage = "back"
        // set offline agent view appearence
        ZDCLoadingErrorView.appearance().buttonFont = FontUtility.mediumFontWithSize(size: 17.0)
        ZDCLoadingErrorView.appearance().buttonBackgroundColor = .black
    }
}

// MARK: - Add to bag Protocols
extension ProductDetailViewController: AddToBagPopupCall {
    func tapOnQtyButton(labelValue: UILabel, isIncrease: Bool) {
        quantityLabel = labelValue
        if isIncrease {
            var value: Int = Int(labelValue.text!)!
            value += 1
            
            if let product = productModel, product.type == .simple {
                
                if value <= (productModel?.extensionAttributes?.stockOptions?.qty)! {
                    labelValue.text = String(value)
                    quantityOrderded = value
                    
                } else { // No more products available
                    showAlertWith(title: AlertTitle.error.localized(), message: AlertMessage.noProductAvailable.localized(), handler: { _ in })
                }
            } else {
                if let model = selectedProductModal { // if any size is selected
                    if value <= model.quantity {  // if requested quantity avialable
                        labelValue.text = String(value)
                        quantityOrderded = value
                        
                    } else { // No more products available
                        showAlertWith(title: AlertTitle.error.localized(), message: AlertMessage.noProductAvailable.localized(), handler: { _ in })
                    }
                } else {
                    // No Size is selected
                    showAlertWith(title: AlertTitle.error.localized(), message: AlertMessage.selectSize.localized(), handler: { _ in})
                }
            }
        } else {
            var value: Int = Int(labelValue.text!)!
            if value == 0  || value == 1 {
                return
            } else {
                value -= 1
                labelValue.text = String(value)
                quantityOrderded = value
            }
        }
    }
    
    func doneButtonAction() {
        UIView.animate(withDuration: 0.45, animations: {
            self.sizeContainer?.frame.origin.y = MainScreen.height
        }, completion: nil)
        
        //        if popupType == .size {
        //            if let colorCode = showDataModel?.colorCode, let sizeCode = seletectedSizeModal?.sizeCode {
        //                addProductToWishList(colorOptionValue: Int(colorCode), sizeOptionValue: Int(sizeCode))
        //            } else {
        //                showAlertWith(title: AlertTitle.error, message: AlertMessage.selectSize.localized(), handler: { _ in
        //                })
        //            }
        //            return
        //        }
        
        if quantityOrderded > 0 {
            // check is user is Guest or registered
            if UserDefaults.standard.getUserToken() == nil {
                // Guest User
                if UserDefaults.standard.getGuestCartToken() == nil {  // Check Either cart is present or not already
                    createGuestCart() // If not craeted already
                } else {
                    addToCartGuest()// Add to cart API
                }
            } else {  // Resigtered User
                //                if UserDefaults.standard.getUserCartToken() == nil {  // Check Either cart is present or not already
                // before adding to cart first we will create cart and then add it to cart to resolve the totals issue
                createRegisteredUserCart()
                //                } else {
                //                    addToCartUser() // Add to cart API
                //                }
            }
        } else {
            showAlertWith(title: AlertTitle.error.localized(), message: AlertMessage.selectSize.localized(), handler: { _ in
            })
        }
    }
    
    func tapOnSizeGuideAction() {
        let modal: [ProductDataModel]?
        
        if let product = productModel, product.type == .simple {
            modal = simpleDataModel
        } else {
            modal = viewModel.dataSequenceModel
        }
        
        guard let url = modal?.filter({$0.type == .URLs}).first?.urlLinks?.sizeGuideline else {
            return
        }
        openSafariwithUrl(url: url, title: NavigationTitle.sizeGuideline.localized())
    }
    
    func removeView() {
        self.updateCartCount() // navigation cart icon with count
        UIView.animate(withDuration: 0.45, animations: {
            self.sizeContainer?.removeFromSuperview()
        }, completion: nil)
    }
}

// MARK: - Change prouduct data via color selection
extension ProductDetailViewController: SendCollectionIndexPath {
    func sendProductModalAndIndexPath(rowNumber: Int) {
        self.showDataModel = self.viewModel.productArray[rowNumber]
        itemSelected = rowNumber
        self.productDetailTableView.reloadData()
        let path = IndexPath(item: 0, section: 0)
        
        self.productDetailTableView.isHidden = true
        Loader.shared.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            // Put your code which should be executed with a delay here
            Loader.shared.hideLoading()
            self.productDetailTableView.scrollToRow(at: path, at: .top, animated: true)
            self.productDetailTableView.isHidden = false
        })
    }
}
