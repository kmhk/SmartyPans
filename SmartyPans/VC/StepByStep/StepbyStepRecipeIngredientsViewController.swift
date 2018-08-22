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
    var firRecipeStepsRef: DatabaseReference!
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet var add_Btn: LGButton!
    @IBOutlet var pauseBtn: UIButton!
    
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var labelIngredientName: UILabel!
    
    @IBOutlet var currentStepNumberLabel: UILabel!
    @IBOutlet var maxStepNumberLabel: UILabel!
    @IBOutlet var stepDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setRound(toView: ingredientImage, radius: ingredientImage.bounds.height/2)
        setRound(toView: pauseBtn, radius: pauseBtn.bounds.height/2)
        pauseBtn.dropCircleButtonShadow()
        labelIngredientName.adjustsFontSizeToFitWidth = true
        labelIngredientName.minimumScaleFactor = 0.8
        getRecipeSteps()
    }
    
    func getRecipeSteps() {
        firRecipeStepsRef = Database.database().reference(withPath: "recipe-steps").child(recipeId)
        
        firRecipeStepsRef?.queryOrdered(byChild: "stepNumber").observe(.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                return
            }
            self.steps = [RecipeStep]()
            for item in snapshot.children {
                let step = RecipeStep(item as! DataSnapshot)
                self.steps.append(step)
            }
            self.setupFirstStep()
        })
    }
    
    func setupFirstStep() {
        maxStepNumberLabel.text = "/ " + String(self.steps.count)
        if self.steps.count > 0 {
            guard let step1 = self.steps.first else { return }
            loadStep(step: step1)
        }
    }
    
    func loadStep(step: RecipeStep) {
        ingredientImage.sd_setImage(with: URL(string: step.ingredientImage), completed: nil)
        labelIngredientName.text = step.ingredient.capitalizingFirstLetter() + " - " + String(step.weight) + step.unit
        weightLabel.text = String(step.weight) + step.unit
        currentStepNumberLabel.text = String(currentStepNumber)
        stepDescriptionLabel.text = step.stepDescription
    }


    @IBAction func nextStepBtnPressed(_ sender: Any) {
        if currentStepNumber == self.steps.count {
            currentStepNumber = 1
        }
        else {
            currentStepNumber = currentStepNumber + 1
        }
        
        let step = self.steps[currentStepNumber-1]
        loadStep(step: step)
        
        //TODO grow progress bar
        //TODO adjust title label
        //ask: button previous? play and stop buttons? or only pause?
    }
}
