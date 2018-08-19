//
//  SaveRecipeViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/19/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import MaterialTextField
import FirebaseDatabase
import Firebase

class SaveRecipeViewController: UIViewController {

    @IBOutlet var recipeNameTxt: MFTextField!
    @IBOutlet var recipeDescTxt: MFTextField!

    var recipeId = ""
    var databaseReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseReference = Database.database().reference()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func saveRecipeBtnPressed(_ sender: Any) {
        let recipe = databaseReference.child("recipes").child(recipeId)
        var recipeMap: [String: Any] = [:]
        var name = ""
        var description = ""
        if(recipeNameTxt.text != nil){
            name = recipeNameTxt.text!
        }
        if(recipeDescTxt.text != nil){
            description = recipeDescTxt.text!
        }
        if(name != ""){
            recipeMap["name"] = name
            recipeMap["description"] = description
            recipeMap["recipeId"] = recipeId
            recipe.setValue(recipeMap)
            
            //let detailViewController: RecipeBreakdownViewController = segue.destination as! RecipeBreakdownViewController
            //detailViewController.recipeId = self.recipeId
            
        }
        
        let recipeVC = self.storyboard?.instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsVC
        recipeVC.recipeId = self.recipeId
        navigationController?.pushViewController(recipeVC, animated: true)
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
