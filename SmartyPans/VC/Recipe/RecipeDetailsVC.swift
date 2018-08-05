//
//  RecipeDetailViewController.swift
//  Smartypans
//
//  Created by Lucky on 04/06/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
//import HCSStarRatingView

class RecipeDetailsVC: UIViewController {

    var stepsArray = [RecipeStep]()
    //@IBOutlet weak var navView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var playStepbyStepButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var share: UIButton!
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    //@IBOutlet weak var labelTime: UILabel!
    //@IBOutlet weak var labelServing: UILabel!
    //@IBOutlet weak var labelCalories: UILabel!
    @IBOutlet var gradientView: UIView!
    
    var recipe: Recipe!
    var user: SPUser!
    var firRecipeRef: DatabaseReference!
    var firRecipeStepsRef: DatabaseReference!
    var firUserRef: DatabaseReference!
    var firUser: User!
    var recipeId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initModel()
        initView()
        addHandle()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addHandle() {
        print("RecipeDetailVC")
        firUser = Api.SUser.CURRENT_USER
        
        firRecipeRef = Database.database().reference(withPath: "recipes").child(recipeId)
        
        firRecipeRef?.observe(.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                return
            }
            let recipe = Recipe(snapshot)
            self.recipe = recipe
            self.recipeNameLabel.text = self.recipe?.name
            //self.labelTime.text = String(Int((self.recipe?.cookTime)!)) + " mins"
            //self.labelCalories.text = String(format: "%.2f cal", (self.recipe?.calories)!)
            self.recipeImage.sd_setImage(with: URL(string: (self.recipe?.recipeImage)!))
            self.tableView.reloadData()
        })
        
        firRecipeStepsRef = Database.database().reference(withPath: "recipe-steps").child(recipeId)
        
        firRecipeStepsRef?.queryOrdered(byChild: "stepNumber").observe(.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                return
            }
            self.stepsArray = [RecipeStep]()
            for item in snapshot.children {
                let step = RecipeStep(item as! DataSnapshot)
                self.stepsArray.append(step)
                self.tableView.reloadData()
            }
        })
        
        firUserRef = Database.database().reference(withPath: "users").child((firUser?.uid)!)
        
        firUserRef?.observe(.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                return
            }
            let user = SPUser(snapshot)
            self.user = user
            self.photoImage.sd_setImage(with: URL(string: self.user?.imageURL ?? ""))
            self.nameLabel.text = self.user?.name
        })
    }
    
    func initModel() {
    }
    
    func initView() {
        // Navbar Gradient View
//        let gradient = CAGradientLayer()
//        let topColor = UIColor(red: 42.0 / 255.0, green: 53.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
//        let bottomColor = UIColor(red: 226.0 / 255.0, green: 35.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
//        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: navView.bounds.size.height)
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
//        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
//        navView.layer.insertSublayer(gradient, at: 0)
        // Play SetepbyStep button radius
        playStepbyStepButton.layer.cornerRadius = 22.0
        playStepbyStepButton.clipsToBounds = true
        // init Star Rating View
        
        /*
        let starRatingView = HCSStarRatingView(frame: CGRect(x: 0, y: 2, width: 120, height: 17))
        starRatingView.maximumValue = 5
        starRatingView.minimumValue = 0
        starRatingView.value = 4
        starRatingView.backgroundColor = UIColor.clear
        starRatingView.tintColor = UIColor(red: 226.0 / 255.0, green: 35.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
        starRatingView.allowsHalfStars = false
        starRatingView.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        ratingView.addSubview(starRatingView)
 */
        // Add Radius
        photoImage.layer.cornerRadius = 17.5
        photoImage.clipsToBounds = true
        
        gradientView.applyBlackAndClearGradient()
    }
    
    @IBAction func back(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    /*
    @objc func didChangeValue(_ sender: HCSStarRatingView) {
    }
 */
    
    // MARK: - IBActions
    @objc func recalculatePressed(_ button: UIButton) {
        performSegue(withIdentifier: "RecordVoice", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowNutrition"{
//            let vc = segue.destination as! NutritionViewController
//            vc.recipeId = self.recipe.recipeId
//            vc.recipeImageURL = self.recipe.recipeImage
        }
    }
    
    @IBAction func onPlayStep(_ sender: Any){
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecipeBreakdownVC") as! RecipeBreakdownViewController
//        vc.recipeId = self.recipeId
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RecipeDetailsVC:UITableViewDelegate, UITableViewDataSource{
    // MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return stepsArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! IntroductionTVCell
            cell.descriptionLabel.text = recipe?.description
            return cell
        } else if indexPath.section == 1 {
            var cell : IngredientsTVCell!
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell2_header") as! IngredientsTVCell
            }else if indexPath.row == stepsArray.count + 1{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell2_footer") as! IngredientsTVCell
                let clearButton = cell.viewWithTag(100) as! UIButton
                let recalculateButton = cell.viewWithTag(101) as! UIButton
                
                clearButton.layer.cornerRadius = 21.0
                clearButton.clipsToBounds = true
                recalculateButton.layer.cornerRadius = 21.0
                recalculateButton.clipsToBounds = true
                recalculateButton.addTarget(self, action: #selector(recalculatePressed(_:)), for: .touchUpInside)
            }else if(stepsArray.count > 0){
                cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! IngredientsTVCell
                
                let imgIG = cell.viewWithTag(100) as! UIImageView
                let lblIGTitle = cell.viewWithTag(101) as! UILabel
                let lblWeight = cell.viewWithTag(102) as! UILabel
                let lblTime = cell.viewWithTag(103) as! UILabel
                
                let step = stepsArray[indexPath.row-1]
                imgIG.sd_setImage(with: URL(string:step.ingredientImage), completed: nil)
                lblIGTitle.text = step.ingredient
                lblWeight.text = String(Int(step.weight)) + " " + step.unit
                lblTime.text = String(Int((step.endTime - step.startTime)/1000)) + " mins"
            }
            
            return cell
        } else {
            var cell = InstructionTVCell()
            
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell3_header") as! InstructionTVCell
            }else if indexPath.row == stepsArray.count + 1{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell3_footer") as! InstructionTVCell
                let playStepbyStepButton = cell.viewWithTag(100) as! UIButton
                playStepbyStepButton.layer.cornerRadius = 21
                playStepbyStepButton.clipsToBounds = true
            }else if stepsArray.count > 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! InstructionTVCell
                let lblStep = cell.viewWithTag(100) as! UILabel
                let lblDesc = cell.viewWithTag(101) as! UILabel
                let step = stepsArray[indexPath.row-1]
                lblStep.text = "Step " + String(Int(step.stepNumber))
                lblDesc.text = step.stepDescription
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 0{
                return 60
            }else if indexPath.row == stepsArray.count + 1 {
                return 80
            }else{
                return 77
            }
        }
        
        if(indexPath.section == 2){
            if indexPath.row == 0{
                return 52
            }else if indexPath.row == stepsArray.count + 1 {
                return 80
            }else{
                return 36
            }
        }
        
        return 160
    }
    
    
}
