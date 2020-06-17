//
//  ProductDetailContainerViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 05/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class ProductDetailContainerViewController: DelamiViewController {
    // MARK: - Variables
    var productDetailPageViewController = UIPageViewController()
    var catalogVM = CatalogViewModel()
    var selectedProductIndex: Int = 0
    var itemArray: [UINavigationController] = []
    var from: NavigateFrom = .catelogPage

    override func viewDidLoad() {
        super.viewDidLoad()
        addCrossBtn(imageName: Image.cross)
        addCartBtn(imageName: #imageLiteral(resourceName: "bag_icon"))
        
        productDetailPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        productDetailPageViewController.dataSource = self
        productDetailPageViewController.view.frame = view.bounds

        for valueIndex in 0...(catalogVM.products.value?.count)! - 1 {
            let viewController = self.getViewControllerAtIndex(valueIndex)
            itemArray.append(viewController)
        }
        
        productDetailPageViewController.setViewControllers([itemArray[selectedProductIndex]], direction: .forward, animated: true, completion: nil)
        addChildViewController(productDetailPageViewController)
        view.addSubview(productDetailPageViewController.view)
        productDetailPageViewController.didMove(toParentViewController: self)
        methodToTriggerAEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCartCount()
    }
    
    override func actionCrossButton() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Method To Triggered the Event For Searched Products with Keywprds....
    fileprivate func methodToTriggerAEvent() {
        let productDetailDic: [String: Any] = [
            API.FacebookEventDicKeys.productname.rawValue: catalogVM.products.value?[selectedProductIndex].name ?? "",
            API.FacebookEventDicKeys.productSku.rawValue: catalogVM.products.value?[selectedProductIndex].sku ?? ""]
        AppEvents.logEvent(.init(FacebookEvents.productDetail.rawValue), parameters: productDetailDic)
    }
}

extension ProductDetailContainerViewController: UIPageViewControllerDataSource {
    func getViewControllerAtIndex(_ index: Int) -> UINavigationController {
        let viewController = (StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.productDetail) as? ProductDetailViewController)!
        viewController.viewModel.from = from
        viewController.productModel = catalogVM.products.value?[index]
        viewController.pageIndex = index
        let navController = UINavigationController.init(rootViewController: viewController)
        return navController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageContent = viewController as? UINavigationController {
            if var index = (pageContent.viewControllers.first as? ProductDetailViewController)?.pageIndex {
                if index == 0 || index == NSNotFound {
                    return nil
                }
                index -= 1
                return itemArray[index]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageContent = viewController as? UINavigationController {
            if var index = (pageContent.viewControllers.first as? ProductDetailViewController)?.pageIndex {
                index += 1
                if index >= (catalogVM.products.value?.count ?? 0) {
                    return nil
                }
                if itemArray.indices.contains(index) {
                    return itemArray[index]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return (productArray?.count)!
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
}
