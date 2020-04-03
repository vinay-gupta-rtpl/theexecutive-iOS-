//
//  CheckoutPaymentOptionsCell.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

enum CheckoutOptionType {
    case shipping
    case payment
}

class CheckoutPaymentOptionsCell: UITableViewCell {
    @IBOutlet weak var paymentOptionTableView: UITableView!
    @IBOutlet weak var borderView: UIView!
    
    var optionType: CheckoutOptionType = .shipping
    var viewModel: CheckoutViewModel?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        paymentOptionTableView.delegate = self
        paymentOptionTableView.dataSource = self
        paymentOptionTableView.separatorStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure() {
        paymentOptionTableView.reloadData()
    }
}

extension CheckoutPaymentOptionsCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if optionType == .shipping {
            return viewModel?.checkoutModel.shippingMethods.count ?? 0
        } else {
            return viewModel?.checkoutModel.paymentMethods.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.checkoutOption, for: indexPath) as? CheckoutOptionCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.checkboxButton.tag = indexPath.row
        cell.nameButton.tag = indexPath.row
        cell.nameButton.titleLabel?.textAlignment = .left
        
        borderView.setShadowOfView(shadowColor: .lightGray, shadowOpacity: 0.5, radious: 2, shadowOffSet: CGSize(width: -1, height: 1))
        
        var selected = false
        if optionType == .shipping {
            if let method = viewModel?.checkoutModel.shippingMethods[indexPath.row] {
//                cell.nameButton.setTitle((method.methodTitle ?? "") + ((method.methodTitle ?? "").isEmpty ? "" : " ") + (method.carrierTitle ?? ""), for: .normal)
                 cell.nameButton.setTitle((method.methodTitle ?? ""), for: .normal)
                selected = method.selected
            }
        } else {
            if let method = viewModel?.checkoutModel.paymentMethods[indexPath.row] {
                cell.nameButton.setTitle(method.title ?? "", for: .normal)
                selected = method.selected ?? false
            }
        }
        cell.checkboxButton.isSelected = selected
        return cell
    }
}

extension CheckoutPaymentOptionsCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}

extension CheckoutPaymentOptionsCell: CheckoutPaymentOptionsCall {
    func tappedOnCheckbox(at index: Int) {
        if optionType == .shipping {
            _ = viewModel?.checkoutModel.shippingMethods.map({ $0.selected = false })
            viewModel?.checkoutModel.shippingMethods[index].selected = true
            _ = viewModel?.checkoutModel.paymentMethods.map({ $0.selected = false })
            viewModel?.requestForPaymentMethods()
        } else {
            _ = viewModel?.checkoutModel.paymentMethods.map({ $0.selected = false })
            viewModel?.checkoutModel.paymentMethods[index].selected = true
        }
        paymentOptionTableView.reloadData()
        viewModel?.shouldCheckForPayNow.value = true
    }
}
