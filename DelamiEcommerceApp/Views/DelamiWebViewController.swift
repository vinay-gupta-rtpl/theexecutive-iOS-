//
//  DelamiWebViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 04/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import WebKit

class DelamiWebViewController: DelamiViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL!
    var navigationTitle: String?
    var isFromPayment: Bool = false
    
    var orderStatus: OrderStatus = .none
    var orderId: String?
    
    let orderCancelUrl: String = "checkout/onepage/cancelled"
    let orderFailureUrl: String = "checkout/onepage/failure"
    let orderSuccessUrl: String = "checkout/onepage/success"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = navigationTitle?.localized().uppercased() ?? NavigationTitle.appName.localized()
        loadView()
        addCrossBtn(imageName: #imageLiteral(resourceName: "back"))
        clearCache()
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Loader.shared.hideLoadingOnView(view: view)
        Loader.shared.hideLoading()
    }
    
    override func actionCrossButton() {
        if isFromPayment {
            self.showAlertWithTwoButton(title: AlertTitle.none.localized(), message: AlertMessage.confirmCancelOrder.localized(), okayHandler: { (_) in
                self.orderStatus = .cancel
                
                // Cancel order from web
                if let orderID = self.orderId {
                    CheckoutViewModel().requestForCancelAnOrder(orderId: orderID)
                }
                
                self.navigationToOrderStatusPage()
            }, cancelHandler: { (_) in
            })
        } else {
            super.actionCrossButton()
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if isFromPayment {
            let urlStr = navigationAction.request.url?.absoluteString ?? ""
            debugPrint("Redirection url: \(urlStr)")
            if urlStr.range(of: orderSuccessUrl) != nil {
                debugPrint("success")
                orderStatus = .success
                navigationToOrderStatusPage()
            } else if urlStr.range(of: orderCancelUrl) != nil {
                debugPrint("cancelled")
                orderStatus = .cancel
                navigationToOrderStatusPage()
            } else if urlStr.range(of: orderFailureUrl) != nil {
                debugPrint("failure")
                orderStatus = .fail
                navigationToOrderStatusPage()
            }
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if isFromPayment {
            Loader.shared.showLoading()
        } else {
            Loader.shared.showLoadingOnView(view: view)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isFromPayment {
            Loader.shared.hideLoading()
        } else {
            Loader.shared.hideLoadingOnView(view: view)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if isFromPayment {
            Loader.shared.hideLoading()
        } else {
            Loader.shared.hideLoadingOnView(view: view)
        }
    }
}

extension DelamiWebViewController {
    func navigationToOrderStatusPage() {
        if let viewController = StoryBoard.checkout.instantiateViewController(withIdentifier: SBIdentifier.orderStatus) as? OrderStatusViewController {
            viewController.orderStatus = orderStatus
            viewController.orderId = orderId
            
            let navigationController = UINavigationController(rootViewController: viewController)
            self.navigationController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func clearCache() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}
