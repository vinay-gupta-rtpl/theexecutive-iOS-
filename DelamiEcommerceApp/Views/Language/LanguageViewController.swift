//
//  LanguageViewController.swift
//  DelamiEcommerceApp
//
//  Created by Nish-Ranosys on 12/03/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

let kLanguageCellLabelTag = 101
let kLanguageCellHeight: CGFloat = 60.0

class LanguageViewController: DelamiViewController {
    // IBOutlets declarations
    @IBOutlet weak var languageListTableView: UITableView!
    
    let viewModel = LanguageViewModel()
    var selectedIndex: Int?
    var comingFromScreen: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = NavigationTitle.selectLanguage.localized()
        languageListTableView.tableFooterView = UIView()
        
        if comingFromScreen == ComingFromScreen.myAccount.rawValue {
            self.tabBarController?.tabBar.isHidden = true
            addBackBtn(imageName: Image.back)
        }
        
        viewModel.languages.bind { (_) in
            if let storeCode = UserDefaults.standard.getStoreCode() {
                self.selectedIndex = self.viewModel.languages.value?.index(where: { ($0.code ?? "") == storeCode })
            }
            self.languageListTableView.reloadData()
        }
        
        if let languages = DataStorage.instance.languages {
            viewModel.languages.value = languages
        } else {
            viewModel.requestForAppSupportedLanguages()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickOnContinue(_ sender: UIButton) {
        if let selectedRow = selectedIndex {
            UserDefaults.instance.setStoreCode(value: viewModel.languages.value?[selectedRow].code)
            UserDefaults.instance.setStoreWebsiteId(value: viewModel.languages.value?[selectedRow].websiteId)
            UserDefaults.instance.setStoreId(value: viewModel.languages.value?[selectedRow].storeID)
            let rootVC = StoryBoard.main.instantiateViewController(withIdentifier: SBIdentifier.rootViewController)  // this is default root view controller of app
            UIApplication.shared.delegate?.window??.rootViewController = rootVC
            
            // call API for configuration using selected store code
             AppConfigurationModel.sharedInstance.requestForAppConfiguration()
        }
    }
}

extension LanguageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kLanguageCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lastSelected = selectedIndex, lastSelected != indexPath.row {
            let cell = tableView.cellForRow(at: IndexPath(row: lastSelected, section: indexPath.section))
            cell?.accessoryType = .none
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        selectedIndex = indexPath.row
    }
}

extension LanguageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.languages.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.CheckoutAndOther.language, for: indexPath)
        if let languageLabel = cell.viewWithTag(kLanguageCellLabelTag) as? UILabel {
            languageLabel.text = viewModel.languages.value?[indexPath.row].name
        }
        
        if let lastSelected = selectedIndex, lastSelected == indexPath.row {
            cell.accessoryType = .checkmark
        }
        return cell
    }
}
