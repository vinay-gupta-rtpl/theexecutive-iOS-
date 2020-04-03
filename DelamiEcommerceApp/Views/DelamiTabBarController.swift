//
//  DelamiTabBarController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 20/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class DelamiTabBarController: UITabBarController {
    var viewModelTabBar = DelamiTabBarViewModel()
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let items = tabBar.items, items.count > 0 {
            for index in 0..<items.count {
                tabBar.items?[index].title = tabBar.items?[index].title?.localized()
            }
        }
    }
    
    // Adjust UITabBar's height:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let newTabBarHeight = defaultTabBarHeight + 11.0
        var newFrame = tabBar.frame
        newFrame.size.height = newTabBarHeight
        newFrame.origin.y = view.frame.size.height - newTabBarHeight
        
        tabBar.frame = newFrame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DelamiTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[1] && UserDefaults.standard.getUserToken() == nil {
            return false
        } else {
            return true
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            if UserDefaults.standard.getUserToken() == nil {
                if let loginNav = StoryBoard.myAccount.instantiateViewController(withIdentifier: SBIdentifier.rootLogin) as? UINavigationController {
                    UIApplication.shared.delegate?.window??.rootViewController?.present(loginNav, animated: true, completion: nil)
                }
            }
        }
        
        if let tappedItemIndex = tabBar.items?.index(of: item), selectedIndex == tappedItemIndex {
            if let navigationControllerArray = self.viewControllers as? [UINavigationController], let homeVC = navigationControllerArray[tappedItemIndex].viewControllers.first as? HomeViewController {
                homeVC.backToTop()
            }
        }
    }
}
