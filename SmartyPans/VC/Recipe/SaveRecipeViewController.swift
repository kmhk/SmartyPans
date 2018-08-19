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
    @IBOutlet var recipeDescTxt: MFTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension SaveRecipeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == recipeNameTxt {
            if (recipeDescTxt.text?.isEmpty)! {
                recipeDescTxt.becomeFirstResponder()
                return true
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}
