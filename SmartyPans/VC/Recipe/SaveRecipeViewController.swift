//
//  SaveRecipeViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/19/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import MaterialTextField

class SaveRecipeViewController: UIViewController {

    @IBOutlet var recipeNameTxt: MFTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
