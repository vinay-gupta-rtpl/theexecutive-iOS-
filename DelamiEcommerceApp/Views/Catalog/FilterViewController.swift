//
//  FilterViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 11/04/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
let kFilterOptionaCellLabelTag = 101

class FilterViewController: DelamiViewController, UITextFieldDelegate, RangeSeekSliderDelegate {
    @IBOutlet weak var rangeSliderNew: RangeSeekSlider!
    @IBOutlet weak var upperRangeTextField: BindingTextfield!
    @IBOutlet weak var lowerRangeTextField: BindingTextfield!
    @IBOutlet weak var filterListTableView: UITableView!
    @IBOutlet weak var priceFilterStackView: UIStackView!
    
    var viewModel: CatalogViewModel?
    weak var delegate: FilterActionDelegate?
    
    var firstTimer: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NavigationTitle.filter.localized()
        addCrossBtn(imageName: #imageLiteral(resourceName: "cancel"))
        addClearButton()
        
        styleUI()
        configureUI()
        updatePrice()
    } /*
    override func viewWillAppear(_ animated: Bool) {
        var index = 0
        for data in (viewModel?.filterData?.filters)! {
            if data.name?.uppercased() == "PRICE" {
                viewModel?.filterData?.filters?.remove(at: index)
            }
            index += 1
        }
    }
*/
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
        if let filters = viewModel?.filterData?.filters {
            for filter in filters {
                if let options = filter.options {
                    for option in options {
                        option.selected = option.selected ?? false ? false : false
                    }
                }
            }
        }
        rangeSliderNew.selectedMinValue = rangeSliderNew.minValue
        rangeSliderNew.selectedMaxValue = rangeSliderNew.maxValue
        rangeSliderNew.updateHandlePositions()
        filterListTableView.reloadData()
    }
    
    func styleUI() {
        upperRangeTextField.setLeftView()
        lowerRangeTextField.setLeftView()
        filterListTableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        rangeSliderNew.delegate = self
        rangeSliderNew.initialColor = .black
        rangeSliderNew.colorBetweenHandles = .black
        rangeSliderNew.lineHeight = 7
        rangeSliderNew.handleBorderWidth = 1
    }
    
    func updatePrice() {
        if let priceRange = viewModel?.priceFilterOption?.options?.first?.value {
            self.priceFilterStackView.isHidden = false
            
            let parts = priceRange.components(separatedBy: "-")
            if parts.count == 2 {
                if let num1 = NumberFormatter().number(from: parts.first ?? ""), let num2 = NumberFormatter().number(from: parts.last ?? "") {
                    rangeSliderNew.isUserInteractionEnabled = true
                    rangeSliderNew.minValue = CGFloat(truncating: num1)
                    rangeSliderNew.maxValue = CGFloat(truncating: num2)
                    
                    if let selectedPrice = viewModel?.selectedPriceRange {
                        let parts1 = selectedPrice.components(separatedBy: "-")
                        rangeSliderNew.selectedMinValue = CGFloat(truncating: NumberFormatter().number(from: parts1.first ?? "")!)
                        rangeSliderNew.selectedMaxValue = CGFloat(truncating: NumberFormatter().number(from: parts1.last ?? "")!)
                    } else {
                        rangeSliderNew.selectedMinValue = CGFloat(truncating: num1)
                        rangeSliderNew.selectedMaxValue = CGFloat(truncating: num2)
                    }
                }
            }
        } else { /* in case of search no price filter come. so hide price range filter. */
            self.priceFilterStackView.isHidden = true
//            rangeSliderNew.minValue = CGFloat(truncating: 0)
//            rangeSliderNew.maxValue = CGFloat(truncating: 0)
//            rangeSliderNew.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func applyButtonAction(_ sender: UIButton) {
        firstTimer = firstTimer ? rangeSliderNew.selectedMinValue == rangeSliderNew.minValue && rangeSliderNew.selectedMaxValue == rangeSliderNew.maxValue : firstTimer
        guard !firstTimer else {
            showAlertWith(title: AlertTitle.none, message: AlertMessage.selectOneOption.localized(), handler: { (_) in
            })
            return
        }
        viewModel?.selectedPriceRange = "\(String(format: "%.0f", rangeSliderNew.selectedMinValue))-\(String(format: "%.0f", rangeSliderNew.selectedMaxValue))"
        delegate?.applySelectedFilters()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        lowerRangeTextField.text = "\(String(Int(minValue)))".changeStringToINR()
        return SystemConstant.defaultCurrencyCode.localized() + " " + "\(String(Int(minValue)))".changeStringToINR()
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue: CGFloat) -> String? {
        upperRangeTextField.text = "\(String(Int(stringForMaxValue)))".changeStringToINR()
        let stringMax = SystemConstant.defaultCurrencyCode.localized() + " " + "\(String(Int(stringForMaxValue)))".changeStringToINR()
        return (stringMax)
    }
    
    @IBAction func upperRangeTextField(_ sender: UITextField) {
        let high: String = sender.text?.replacingOccurrences(of: ".", with: "") ?? ""
        let low: String = lowerRangeTextField.text?.replacingOccurrences(of: ".", with: "") ?? ""
        let maxvalue = Float(rangeSliderNew.maxValue)
        
        if let lowDouble = Float(low), let highDouble = Float(high) {
            if highDouble > lowDouble && highDouble <= maxvalue {
                if let num = NumberFormatter().number(from: high) {
                    rangeSliderNew.selectedMaxValue = CGFloat(truncating: num)
                    rangeSliderNew.updateHandlePositions()
                }
            } else {
                let alertController = UIAlertController(title: AlertTitle.alert.localized(), message: AlertMessage.enterCorrectAmount.localized(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: AlertButton.okay.localized(), style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func lowerRangeTextField(_ sender: UITextField) {
        let low = sender.text?.replacingOccurrences(of: ".", with: "") ?? ""
        let high = upperRangeTextField.text?.replacingOccurrences(of: ".", with: "") ?? ""
        let minvalue = Float(rangeSliderNew.minValue)
        
        if let lowDouble = Float(low), let highDouble = Float(high) {
            if lowDouble < highDouble && lowDouble >= minvalue {
                if let num = NumberFormatter().number(from: low) {
                    rangeSliderNew.selectedMinValue = CGFloat(truncating: num)
                    rangeSliderNew.updateHandlePositions()
                }
            } else {
                let alertController = UIAlertController(title: AlertTitle.alert.localized(), message: AlertMessage.enterCorrectAmount.localized(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: AlertButton.okay.localized(), style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.filterData?.filters?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filterData?.filters?[section].options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: filterListTableView.frame.width, height: 44.0))
        headerView.backgroundColor = .white
        
        let filterCategoryLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: filterListTableView.frame.width - 60, height: 44.0))
        filterCategoryLabel.text = viewModel?.filterData?.filters?[section].name
        filterCategoryLabel.font = FontUtility.mediumFontWithSize(size: 15.0)
        headerView.addSubview(filterCategoryLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.filter, for: indexPath)
        if let filterLabel = cell.viewWithTag(kFilterOptionaCellLabelTag) as? UILabel {
            filterLabel.text = viewModel?.filterData?.filters?[indexPath.section].options?[indexPath.row].label?.replacingOccurrences(of: "&amp;", with: "&")
        }
        if let isOptionSelected = viewModel?.filterData?.filters?[indexPath.section].options?[indexPath.row].selected, isOptionSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastSelectedIndex = viewModel?.filterData?.filters?[indexPath.section].options?.index(where: {$0.selected ?? false}) {
            let cell = tableView.cellForRow(at: IndexPath(row: lastSelectedIndex, section: indexPath.section))
            cell?.accessoryType = .none
            viewModel?.filterData?.filters?[indexPath.section].options?[lastSelectedIndex].selected = false
        }
        
        firstTimer = false
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        viewModel?.filterData?.filters?[indexPath.section].options?[indexPath.row].selected = true
    }
}

extension UITextField {
    func setLeftView() {
        let idr = UILabel(frame: CGRect(x: 10.0, y: 0, width: 32, height: self.frame.height))
        idr.text = SystemConstant.defaultCurrencyCode.localized()
        idr.font = idr.font.withSize(15)
        self.leftView = idr
        self.leftViewMode = UITextFieldViewMode.always
    }
}
