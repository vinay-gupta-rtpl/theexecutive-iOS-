//
//  MyOrderViewController.swift
//  DelamiEcommerceApp
//
//  Created by Rishi Gupta on 5/11/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class MyOrderViewController: DelamiViewController {
    var myOrderModelArray = [MyOrderModel]()
    
    @IBOutlet weak var noOrderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.isHidden = false
        Loader.shared.showLoading()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavTitles.myOrder.localized()
        addBackBtn(imageName: Image.back)
    }
    
    func getData() {
        MyOrderModel().getOrderHistory(success: { [weak self] (response) in
            if let responseArray = response as? [MyOrderModel] {
                self?.myOrderModelArray = responseArray
                Loader.shared.hideLoading()
                if self?.myOrderModelArray.count == 0 {
                    self?.tableView.isHidden = true
                }
                self?.tableView.reloadData()
            }
            }, failure: { [weak self] (error) in
                Loader.shared.hideLoading()
                self?.showAlertWith(title: AlertTitle.alert.localized(), message: "\(error?.localizedDescription ?? "")", handler: nil)
        })
    }
}
extension MyOrderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myOrderModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.Order.myOrder, for: indexPath) as? MyOrderTableViewCell else {
            fatalError("Could not load MyOrderTableViewCell ")
        }
        cell.cellIndex = indexPath
        cell.orderCellDelegate = self
        
        let myOrderModel = myOrderModelArray[indexPath.row]
        cell.setUpData(myOrderModel: myOrderModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveToNextPage(indexPath: indexPath, isMoveToDetail: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.updateStringsForApplicationGlobalLanguage()
    }
    
    func moveToNextPage(indexPath: IndexPath, isMoveToDetail: Bool) {
        if isMoveToDetail {
            guard let detailVC = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.orderDetail) as? OrderDetailViewController else { return }
            detailVC.orderNo = "\(myOrderModelArray[indexPath.row].productId ?? "")"
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            guard let returnVC = StoryBoard.order.instantiateViewController(withIdentifier: SBIdentifier.returnOrder) as? OrderReturnViewController else { return }
            returnVC.orderNo = "\(myOrderModelArray[indexPath.row].productId ?? "")"
            self.navigationController?.pushViewController(returnVC, animated: true)
        }
    }
}

extension MyOrderViewController: MyOrderTableCellDelegate {
    func returnButtonAction(indexPath: IndexPath) {
        moveToNextPage(indexPath: indexPath, isMoveToDetail: false)
    }
}
