//
//  WishlistViewModel.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 02/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class WishlistViewModel: NSObject {
    var wishlistItems: Dynamic<[WishlistItemModel]?> = Dynamic(nil)
    var totalProducts: Int = 0
}

extension WishlistViewModel {
    func fetchWishlistItemList() {
        weak var weakSelf = self
        ConnectionManager().getWishlistItems(success: { (response) in
            if let jsonData = response as? Data {
                do {
                    let result = try JSONDecoder().decode(WishlistItemListModel.self, from: jsonData)
                    weakSelf?.totalProducts = result.itemCount
                    weakSelf?.wishlistItems.value = result.items
                } catch let msg {
                    debugPrint("JSON serialization error:" + "\(msg)")
                }
            } else {
                debugPrint("failure: jsonData is not available")
            }
        }, failure: { (_) in
            Loader.shared.hideLoading()
            print("error: Wishlist API error")
        })
    }
    
    func removeWishlistItem(itemId: Int64) {
        weak var weakSelf = self
        ConnectionManager().removeWishlistItem(wishlistItemId: itemId, success: { (_) in
            weakSelf?.fetchWishlistItemList()
        }, failure: { (_) in
            Loader.shared.hideLoading()
            print("error: Wishlist API error")
        })
    }
    
    func moveItemToCart(itemId: Int64, success: @escaping ((_ response: AnyObject?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        ConnectionManager().moveItemToCartFromWishlist(wishlistItemId: itemId, success: success, failure: failure)
    }
}
