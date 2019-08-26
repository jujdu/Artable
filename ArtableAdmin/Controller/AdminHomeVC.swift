//
//  ViewController.swift
//  ArtableAdmin
//
//  Created by Michael Sidoruk on 18/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
    }

    @objc func addCategory() {
        performSegue(withIdentifier: Segues.ToAddEditCategoryVC, sender: self)
    }
}

