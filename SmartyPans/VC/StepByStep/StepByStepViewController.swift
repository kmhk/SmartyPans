//
//  StepByStepViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/7/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
//import HCSStarRatingView

class StepByStepViewController: UIViewController {
    var stepsArray = [RecipeStep]()
    //@IBOutlet weak var navView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var playStepbyStepButton: UIButton!
    @IBOutlet weak var tableViewIngredients: UITableView!
    @IBOutlet weak var tableViewInstructions: UITableView!
    @IBOutlet weak var share: UIButton!
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    //@IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var labelCalories: UILabel!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var instructionBtn: UIButton!
    @IBOutlet var ingredientsBtn: UIButton!
    @IBOutlet var tabBtnsContainerView: UIView!
    @IBOutlet var tabBtnSelectedIndicatorView: UIView!
    @IBOutlet var tabBtnSelectedIndicatorViewLeading: NSLayoutConstraint!
    @IBOutlet var ingredientsDetailContainerView: UIView!
    @IBOutlet var instructionDetailContainerView: UIView!
    @IBOutlet var tabBtnsContainerTopToSafeArea: NSLayoutConstraint!
    @IBOutlet var tabBtnsContainerTopToHeaderView: NSLayoutConstraint!
    @IBOutlet var startCookingBtnWidth: NSLayoutConstraint!
    
    var recipe: Recipe!
    var user: SPUser!
    var firRecipeRef: DatabaseReference!
    var firRecipeStepsRef: DatabaseReference!
    var firUserRef: DatabaseReference!
    var firUser: User!
    var recipeId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewInstructions.rowHeight = UITableViewAutomaticDimension
        self.tableViewInstructions.estimatedRowHeight = 44.0
        
        self.tableViewIngredients.rowHeight = UITableViewAutomaticDimension
        self.tableViewIngredients.estimatedRowHeight = 80.0
        self.tableViewIngredients.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        initModel()
        initView()
        addHandle()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandle() {
        firUser = Api.SUser.CURRENT_USER
        
        firRecipeRef = Database.database().reference(withPath: "recipes").child(recipeId)
        
        firRecipeRef?.observe(.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                return
            }
            let recipe = Recipe(snapshot)
            self.recipe = recipe
            self.recipeNameLabel.text = self.recipe?.name
            if let cookTime = self.recipe?.cookTime{
                let intCookTime = Int(cookTime)
                self.labelTime.text = String(intCookTime) + (intCookTime > 1 ? " mins" : " min")
            }
            self.labelCalories.text = String(format: "%.0f kCal", (self.recipe?.calories)!)
            self.recipeImage.sd_setImage(with: URL(string: (self.recipe?.recipeImage)!))
            self.tableViewInstructions.reloadData()
            self.tableViewIngredients.reloadData()
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
                self.tableViewInstructions.reloadData()
                self.tableViewIngredients.reloadData()
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
        playStepbyStepButton.layer.cornerRadius = playStepbyStepButton.frame.size.height/2
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
        tabBtnsContainerView.round(corners: [.topLeft, .topRight], radius: 10)
        instructionBtnPressed(instructionBtn)
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
    
    @IBAction func instructionBtnPressed(_ sender: Any) {
        if instructionBtn.isSelected {
            moveTabDetailContainerViews()
            return
        }
        instructionBtn.isSelected = true
        ingredientsBtn.isSelected = false
        
        tabBtnSelectedIndicatorViewLeading.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        instructionDetailContainerView.isHidden = false
        ingredientsDetailContainerView.isHidden = true
    }
    
    func moveTabDetailContainerViews(){
        if tabBtnsContainerTopToHeaderView.isActive {
            tabBtnsContainerTopToHeaderView.isActive = false
            tabBtnsContainerTopToSafeArea.isActive = true
            makeStartCookingBtnSmall()
        }
        else {
            tabBtnsContainerTopToHeaderView.isActive = true
            tabBtnsContainerTopToSafeArea.isActive = false
            makeStartCookingBtnBig()
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func moveTabDetailContainerViewsUp() {
        if tabBtnsContainerTopToHeaderView.isActive {
            tabBtnsContainerTopToHeaderView.isActive = false
            tabBtnsContainerTopToSafeArea.isActive = true
            makeStartCookingBtnSmall()
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func moveTabDetailContainerViewsDown() {
        if tabBtnsContainerTopToSafeArea.isActive {
            tabBtnsContainerTopToHeaderView.isActive = true
            tabBtnsContainerTopToSafeArea.isActive = false
            makeStartCookingBtnBig()
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func makeStartCookingBtnSmall() {
        if startCookingBtnWidth.constant > 50 {
            startCookingBtnWidth.constant = 50
            playStepbyStepButton.setTitle("", for: .normal)
            //            UIView.animate(withDuration: 1.5) {
            //                self.view.layoutIfNeeded()
            //            }
        }
        
    }
    
    func makeStartCookingBtnBig() {
        if startCookingBtnWidth.constant == 50 {
            startCookingBtnWidth.constant = 213
            playStepbyStepButton.setTitle("START COOKING", for: .normal)
            //            UIView.animate(withDuration: 1.5) {
            //                self.view.layoutIfNeeded()
            //            }
        }
        
    }
    
    @IBAction func ingredientsBtnPressed(_ sender: Any) {
        if ingredientsBtn.isSelected {
            moveTabDetailContainerViews()
            return
        }
        ingredientsBtn.isSelected = true
        instructionBtn.isSelected = false
        
        tabBtnSelectedIndicatorViewLeading.constant = ingredientsBtn.bounds.width
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        instructionDetailContainerView.isHidden = true
        ingredientsDetailContainerView.isHidden = false
    }
    
    
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

extension StepByStepViewController:UITableViewDelegate, UITableViewDataSource{
    // MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableViewInstructions {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewInstructions {
            if section == 0{
                return 1
            }
            return stepsArray.count + 1
        }
        else {
            
            return stepsArray.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewInstructions {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! IntroductionTVCell
                cell.descriptionLabel.text = recipe?.description
                return cell
            } else {
                var cell = InstructionTVCell()
                
                if indexPath.row == 0{
                    cell = tableView.dequeueReusableCell(withIdentifier: "cell3_header") as! InstructionTVCell
                }else if stepsArray.count > 0{
                    cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! InstructionTVCell
                    cell.isFirstCell = indexPath.row == 1
                    cell.isLastCell = indexPath.row == stepsArray.count
                    cell.drawDottedLines()
                    let lblStep = cell.viewWithTag(100) as! UILabel
                    let stepContainerView = lblStep.superview!
                    let lblDesc = cell.viewWithTag(101) as! UILabel
                    let step = stepsArray[indexPath.row-1]
                    lblStep.text = String(Int(step.stepNumber))
                    lblDesc.text = step.stepDescription
                    stepContainerView.asCircle()
                    stepContainerView.dropSmallCircleButtonShadow()
                    
                }
                return cell
            }
        }
        else {
            var cell : IngredientsTVCell!
            if indexPath.row == stepsArray.count + 1{
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
                let imgContainerView = imgIG.superview!
                imgIG.asCircle()
                imgContainerView.asCircle()
                imgContainerView.dropSmallCircleButtonShadow()
                
                let step = stepsArray[indexPath.row]
                imgIG.sd_setImage(with: URL(string:step.ingredientImage), completed: nil)
                let ingredientTxt = step.ingredient
                lblIGTitle.text = ingredientTxt.capitalizingFirstLetter()
                lblWeight.text = String(Int(step.weight)) + " " + step.unit
                lblTime.text = String(Int((step.endTime - step.startTime)/1000)) + " mins"
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableViewInstructions {
            return UITableViewAutomaticDimension
            
            //            if(indexPath.section == 1){
            //                if indexPath.row == 0{
            //                    return 52
            //                }else if indexPath.row == stepsArray.count + 1 {
            //                    return 80
            //                }else{
            //                    return 36
            //                }
            //            }
            //
            //            return 160
        }
        else {
            return UITableViewAutomaticDimension
            //                if indexPath.row == 0{
            //                    return 60
            //                }else if indexPath.row == stepsArray.count + 1 {
            //                    return 80
            //                }else{
            //                    return 77
            //                }
        }
    }
    
    
}

extension StepByStepViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if instructionBtn.isSelected {
            if scrollView == tableViewInstructions {
                var currentLocation = scrollView.contentOffset.y
                //print("current location: \(currentLocation)")
                if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
                    //print("up")
                    if currentLocation <= 0 {
                        moveTabDetailContainerViewsDown()
                    }
                }
                else {
                    //print("down")
                    moveTabDetailContainerViewsUp()
                }
            }
        }
        
        if ingredientsBtn.isSelected {
            if scrollView == tableViewIngredients {
                var currentLocation = scrollView.contentOffset.y
                print("current location: \(currentLocation)")
                if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
                    print("up")
                    if currentLocation <= -20 {
                        moveTabDetailContainerViewsDown()
                    }
                }
                else {
                    print("down")
                    moveTabDetailContainerViewsUp()
                }
            }
        }
    }
}

