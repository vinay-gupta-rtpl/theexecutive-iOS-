//
//  SettingViewController.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 06/06/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class SettingViewController: DelamiViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = NavTitles.setting.localized().uppercased()
        addBackBtn(imageName: Image.back)
    }
    
    @IBAction func tapOnGoToSetting(_ sender: Any) {
        let urlObj = URL(string: UIApplicationOpenSettingsURLString)!
        if UIApplication.shared.canOpenURL(urlObj) {
            UIApplication.shared.open(urlObj, options: [:], completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
