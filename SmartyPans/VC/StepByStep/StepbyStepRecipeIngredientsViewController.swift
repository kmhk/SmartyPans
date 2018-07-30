//
//  StepbyStepRecipeIngredientsViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 7/29/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Speech
import SVProgressHUD
import Firebase
import FirebaseDatabase
import MBCircularProgressBar
import LGButton

class StepbyStepRecipeIngredientsViewController: UIViewController {

    @IBOutlet weak var weightLabel: UILabel!
    
    var imageUrl = ""
    var ingredientName = ""
    
    var steps = [RecipeStep]()
    var currentStepNumber = 1
    var currentStep: RecipeStep?
    var recipeId = ""
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet var add_Btn: LGButton!
    @IBOutlet var pauseBtn: UIButton!
    
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var labelIngredientName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRound(toView: ingredientImage, radius: ingredientImage.bounds.height/2)
        setRound(toView: pauseBtn, radius: pauseBtn.bounds.height/2)
        pauseBtn.dropCircleButtonShadow()
    }


}
