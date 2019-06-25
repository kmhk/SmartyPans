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
    
    @IBOutlet weak var timeToCook: UILabel!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet var add_Btn: LGButton!
    @IBOutlet var pauseBtn: UIButton!
    
    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var labelIngredientName: UILabel!
    
    @IBOutlet var currentStepNumberLabel: UILabel!
    @IBOutlet var maxStepNumberLabel: UILabel!
    @IBOutlet var stepDescriptionLabel: UILabel!
    
    @IBOutlet var stepsProgressBar: NSLayoutConstraint!
    @IBOutlet var pauseBtnContainerView: UIView!
    @IBOutlet var playAndStopBtnContainerView: UIView!
    
    @IBOutlet var playBtn: UIButton!
    
    @IBOutlet var stopBtn: UIButton!
    
    var seconds = 5 //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setRound(toView: ingredientImage, radius: ingredientImage.bounds.height/2)
        setRound(toView: pauseBtn, radius: pauseBtn.bounds.height/2)
        pauseBtn.dropCircleButtonShadow()
        
        setRound(toView: playBtn, radius: playBtn.bounds.height/2)
        playBtn.dropCircleButtonShadow()
        setRound(toView: stopBtn, radius: stopBtn.bounds.height/2)
        stopBtn.dropCircleButtonShadow()
        
        labelIngredientName.adjustsFontSizeToFitWidth = true
        labelIngredientName.minimumScaleFactor = 0.8
        
        pauseBtnContainerView.alpha = 1
        playAndStopBtnContainerView.alpha = 0
        
        pauseBtnContainerView.isHidden = false
        playAndStopBtnContainerView.isHidden = true
        
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
        self.progressBar.value = 0
        let screenWidth = UIScreen.main.bounds.width
        let progressPerc = (CGFloat(currentStepNumber))/(CGFloat(self.steps.count))
        let progressAdvance = screenWidth * progressPerc
        stepsProgressBar.constant = progressAdvance
        
        ingredientImage.sd_setImage(with: URL(string: step.ingredientImage), completed: nil)
        labelIngredientName.text = step.ingredient.capitalizingFirstLetter()
            + " - " + String(format: "%.2f", step.weight) + " " + step.unit
//        weightLabel.text = String(step.weight) + step.unit
        timeToCook.text = timeString(time: TimeInterval(seconds))
        currentStepNumberLabel.text = String(currentStepNumber)
        stepDescriptionLabel.text = step.stepDescription
        //self.startWeightAnimation(weight: 100)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
            //self.runTimer()
            self.startWeightAnimation(weight: 100)
        }
//        seconds = 5
    }
    
    
    
    func startWeightAnimation(weight: CGFloat){
        UIView.animate(withDuration: 2, animations: {() -> Void in
            self.progressBar.value = weight
        })

        
    }
    
    func resetWeightAnimation(){
        UIView.animate(withDuration: 1, animations: {() -> Void in
            self.progressBar.value = 0
        })
    }


    @IBAction func nextStepBtnPressed(_ sender: Any) {
        self.progressBar.value = 0
        
        if currentStepNumber == self.steps.count {
            currentStepNumber = 1
        }
        else {
            currentStepNumber = currentStepNumber + 1
        }
        if(currentStepNumber >= self.steps.count){
            self.performSegue(withIdentifier: "showDoneScreen", sender: self)
        }
        let step = self.steps[currentStepNumber-1]
        
        self.loadStep(step: step)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(StepbyStepRecipeIngredientsViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate "time's up!"
        } else {
            seconds -= 1
            timeToCook.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pauseBtnContainerView.alpha = 1
            self.playAndStopBtnContainerView.alpha = 0
        }) { (complete) in
            self.pauseBtnContainerView.isHidden = false
            self.playAndStopBtnContainerView.isHidden = true
        }
        
    }
    @IBAction func stopBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pauseBtnContainerView.alpha = 0
            self.playAndStopBtnContainerView.alpha = 1
        }) { (complete) in
            self.pauseBtnContainerView.isHidden = true
            self.playAndStopBtnContainerView.isHidden = false
        }
    }
    
    
}
