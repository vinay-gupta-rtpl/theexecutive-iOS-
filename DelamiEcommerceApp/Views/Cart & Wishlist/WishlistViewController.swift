//
//  WishlistViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class WishlistViewController: DelamiViewController {
    // IBOutlet declaration
    @IBOutlet weak var wishlistTableView: UITableView!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var noResultLabel: UILabel!
    
    var viewModel = WishlistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NavigationTitle.wishlist
        
        wishlistTableView.tableFooterView = UIView()
        wishlistTableView.register(UINib(nibName: CellIdentifier.CartAndWishlist.cell, bundle: nil), forCellReuseIdentifier: CellIdentifier.CartAndWishlist.cell)
        
        viewModel.wishlistItems.bind { _ in
            Loader.shared.hideLoading()
            if self.viewModel.totalProducts == 0 {
                self.totalCountLabel.isHidden = true
                self.noResultLabel.isHidden = false
                self.wishlistTableView.isHidden = true
                
                if let storeCode = UserDefaults.instance.getStoreCode(), storeCode == "ID" {
                    self.noResultLabel.text = "Daftar Wishlist anda kosong" + "!"
                } else {
                   self.noResultLabel.text = "Your wishlist is empty".localized() + "!"
                }
            } else {
                self.noResultLabel.isHidden = true
                self.totalCountLabel.isHidden = false
                self.wishlistTableView.isHidden = false
                
                let totalString = ConstantString.itemsInWishlist.localized()
                
                if let number = Int(totalString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                 self.totalCountLabel.text = totalString.replacingOccurrences(of: String(number), with: String(self.viewModel.totalProducts))
                }
                
//                self.totalCountLabel.text = ConstantString.total.localized() + " " + String(self.viewModel.totalProducts) + " " + ConstantString.itemsInWishlist.localized()
            }
            self.wishlistTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.getUserToken() == nil {
            noResultLabel.isHidden = false
            noResultLabel.text = AlertValidation.Invalid.tapOnWishlist.localized()
            totalCountLabel.isHidden = true
            wishlistTableView.isHidden = true
        } else {
            noResultLabel.isHidden = true
            totalCountLabel.isHidden = false
            wishlistTableView.isHidden = false
            
            Loader.shared.showLoading()
            viewModel.fetchWishlistItemList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension WishlistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.wishlistItems.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CartAndWishlist.cell, for: indexPath) as? CartAndWishlistCell else {
            return UITableViewCell()
        }
        cell.tag = indexPath.row
        cell.productName.tag = indexPath.row
        cell.productImageView.tag = indexPath.row
        cell.cellType = .wishlist
        cell.wishlistCallDelegate = self
        cell.configureWishlistCell(wishlistItem: viewModel.wishlistItems.value?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
}

extension WishlistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension WishlistViewController: WishlistCall {
    func tappedOnWishlistRemoveButton(index: Int?) {
        if let selectedIndex = index, let itemId = self.viewModel.wishlistItems.value?[selectedIndex].productWishlistId {
            self.showAlertWithTwoButton(title: AlertTitle.none, message: AlertMessage.wishlistRemove.localized(), okayHandler: { _ in
                Loader.shared.showLoading()
                self.viewModel.removeWishlistItem(itemId: itemId)
            }, cancelHandler: { _ in
                
            })
        }
    }
    
    func tappedOnWishlistMoveToCartButton(index: Int?) {
        if let selectedIndex = index, let item = self.viewModel.wishlistItems.value?[selectedIndex] {
            if (item.type ?? .configurable) == .configurable {
                navigateToProductDetail(index: index)
                return
            } else {
                //            guard let isInStock = item.stockInfo?.isInStock, isInStock else {
                //                return
                //            }
                
                Loader.shared.showLoading()
                self.viewModel.moveItemToCart(itemId: item.productWishlistId ?? 0, success: { (response) in
                    Loader.shared.hideLoading()
                    if let message = response as? String {
                        self.showAlertWith(title: AlertTitle.none, message: message, handler: { (_) in
                            Loader.shared.hideLoading()
                            self.viewModel.fetchWishlistItemList()
                        })
                    }
                }, failure: { (error) in
                    Loader.shared.hideLoading()
                    var message = "Error adding item to cart."
                    if let errorMessage = error?.userInfo["message"] as? String {
                        message = errorMessage
                    }
                    self.showAlertWith(title: AlertTitle.none, message: message, handler: { (_) in
                        
                    })
                })
            }
        }
    }
    
    func navigateToProductDetail(index: Int?) {
        if let selectedIndex = index, let sku = self.viewModel.wishlistItems.value?[selectedIndex].sku {
            let viewModal = ProductDetailViewModel()
            viewModal.getProductDetails(skuId: sku, success: { (response) in
                if let viewController = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController {
                    viewController.productModel = response as? ProductModel
                    viewController.comingFrom = ComingFromScreen.wishlist.rawValue
                    let nav = UINavigationController.init(rootViewController: viewController)
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }, failure: { (_) in
                
            })
        }
    }
}
