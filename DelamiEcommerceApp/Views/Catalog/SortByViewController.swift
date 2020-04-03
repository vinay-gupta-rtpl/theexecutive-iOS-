//
//  SortByViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 11/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

let kSortOptionaCellLabelTag = 101
let kSortByOptionCellHeight: CGFloat = 60.0

class SortByViewController: DelamiViewController {
    @IBOutlet weak var sortOptionsTableView: UITableView!
    
    var viewModel: CatalogViewModel?
    weak var delegate: SortActionDelegate?
    var selectedIndex: Int?
    var hasPreviousSort = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = NavigationTitle.sortBy.localized().uppercased()
        addCrossBtn(imageName: Image.cross)
        addClearButton()
        sortOptionsTableView.tableFooterView = UIView()
        selectedIndex = viewModel?.sortOptions?.index(where: {$0.selected!})
        hasPreviousSort = selectedIndex != nil ? true : false
        
        if viewModel?.sortOptions?.count ?? 0 > 0 {
            sortOptionsTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func addClearButton() {
        let rightBarBtn = UIButton()
        rightBarBtn.setTitle(ButtonTitles.clear.localized(), for: .normal)
        rightBarBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        rightBarBtn.setTitleColor(UIColor.black, for: .normal)
        rightBarBtn.titleLabel?.font = FontUtility.regularFontWithSize(size: 15.0)
        rightBarBtn.addTarget(self, action: #selector(tapOnClearAll), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarBtn)
    }
    
    @objc func tapOnClearAll() {
        selectedIndex = nil
        viewModel?.selectedSort = nil
        if let options = viewModel?.sortOptions, options.count > 0 {
            for option in options {
                option.selected = false
            }
            sortOptionsTableView.reloadData()
        } else {
            return
        }
    }
    
    @IBAction func applyButtonAction(_ sender: UIButton) {
        guard let index = selectedIndex else {
            if !hasPreviousSort {
                showAlertWith(title: AlertTitle.none, message: AlertMessage.selectOneOption.localized(), handler: { (_) in
                })
            } else {
                self.navigationController?.dismiss(animated: true, completion: nil)
                delegate?.applySelectedSortOrder()
            }
            return
        }
        viewModel?.sortOptions?[index].selected = true
        viewModel?.selectedSort = viewModel?.sortOptions?[index].attributeCode
        
        if viewModel?.sortOptions?[index].attributeName?.range(of: Direction.asc.rawValue.localized()) != nil || viewModel?.sortOptions?[index].attributeName?.range(of: Direction.desc.rawValue.localized()) != nil {
            viewModel?.sortDirection = viewModel?.sortOptions?[index].attributeName?.range(of: Direction.asc.rawValue.localized()) != nil ? .asc : .desc
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        delegate?.applySelectedSortOrder()
    }
}

extension SortByViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sortOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.sortOption, for: indexPath)
        if let sortLabel = cell.viewWithTag(kSortOptionaCellLabelTag) as? UILabel {
            sortLabel.text = viewModel?.sortOptions?[indexPath.row].attributeName
        }
        
        if let isOptionSelected = viewModel?.sortOptions?[indexPath.row].selected, isOptionSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension SortByViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kSortByOptionCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastSelected = selectedIndex, lastSelected != indexPath.row {
            let cell = tableView.cellForRow(at: IndexPath(row: lastSelected, section: indexPath.section))
            cell?.accessoryType = .none
            viewModel?.sortOptions?[lastSelected].selected = false
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        selectedIndex = indexPath.row
    }
}
