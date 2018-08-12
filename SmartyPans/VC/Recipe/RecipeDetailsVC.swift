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
import ProgressHUD
//import HCSStarRatingView

class RecipeDetailsVC: UIViewController {

    var stepsArray = [RecipeStep]()
    //@IBOutlet weak var navView: UIView!
    @IBOutlet weak var ratingView: UIView!
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
    
    @IBOutlet var tabBtnsContainerTopSpace: NSLayoutConstraint!
    
    @IBOutlet var makePhotoContainerView: UIView!
    @IBOutlet var makePhotoBtn: UIButton!
    var picker:UIImagePickerController?=UIImagePickerController()
    
    var recipe: Recipe!
    var user: SPUser!
    var firRecipeRef: DatabaseReference!
    var firRecipeStepsRef: DatabaseReference!
    var firUserRef: DatabaseReference!
    var firUser: User!
    var recipeId = ""
    
    var kTabBtnsTopSpaceUp: CGFloat = 0
    var kTabBtnsTopSpaceDown: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kTabBtnsTopSpaceUp = 60 + topSafeAreaInsets()
        kTabBtnsTopSpaceDown = (self.view.bounds.height/2) - 10
        self.tabBtnsContainerTopSpace.constant = self.kTabBtnsTopSpaceDown
        
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
            if let cookTime = self.recipe?.cookTime{
                let intCookTime = Int(cookTime)
                self.labelTime.text = String(intCookTime) + (intCookTime > 1 ? " mins" : " min")
            }
            self.labelCalories.text = String(format: "%.0f kCal", (self.recipe?.calories)!)
            self.recipeImage.sd_setImage(with: URL(string: (self.recipe?.recipeImage)!))
            if let recipe = self.recipe, recipe.recipeImage.count > 0 {
                self.makePhotoContainerView.isHidden = true
            }
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
        picker?.delegate = self
        // Add Radius
        photoImage.layer.cornerRadius = photoImage.frame.size.height/2
        photoImage.clipsToBounds = true
        
        setRound(toView: makePhotoBtn, radius: makePhotoBtn.bounds.height/2)
        makePhotoBtn.dropCircleButtonShadow()
        
        gradientView.applyBlackAndClearGradient()
        tabBtnsContainerView.round(corners: [.topLeft, .topRight], radius: 10)
        instructionBtnPressed(instructionBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.sublayers?.first?.frame = gradientView.bounds
        tabBtnsContainerView.round(corners: [.topLeft, .topRight], radius: 10)
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
        DispatchQueue.main.async {
            if self.tabBtnsContainerTopSpace.constant != self.kTabBtnsTopSpaceUp {
                self.tabBtnsContainerTopSpace.constant = self.kTabBtnsTopSpaceUp
                //self.makeStartCookingBtnSmall()
            }
            else {
                self.tabBtnsContainerTopSpace.constant = self.kTabBtnsTopSpaceDown
                //self.makeStartCookingBtnBig()
            }
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func moveTabDetailContainerViewsUp() {
        if tabBtnsContainerTopSpace.constant != kTabBtnsTopSpaceUp {
            tabBtnsContainerTopSpace.constant = kTabBtnsTopSpaceUp
            //makeStartCookingBtnSmall()
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func moveTabDetailContainerViewsDown() {
        if tabBtnsContainerTopSpace.constant == kTabBtnsTopSpaceUp {
            tabBtnsContainerTopSpace.constant = kTabBtnsTopSpaceDown
            //makeStartCookingBtnBig()
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
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
    
    @IBAction func makePhotoBtnPressed(_ sender: Any) {
        openSheet()
    }
    
    func openSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            self.openCamera()
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photo Gallery", style: .default)
        { _ in
            self.openGallary()
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func openGallary()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Photo Gallery Error", message: "Can't access to Photo Gallery", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
    {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}
extension RecipeDetailsVC: UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
       
        self.recipeImage.image = chosenImage
        self.makePhotoContainerView.isHidden = true
        let imageData = UIImageJPEGRepresentation(chosenImage, 0.1)
        dismiss(animated: true, completion: {
            ProgressHUD.show("Uploading...")
            PostApi.uploadRecipeImage(imageData: imageData!, recipeId: self.recipe.recipeId, onSuccess: { (imageURL) in
                self.recipeImage.sd_setImage(with: URL(string: imageURL))
                self.recipe?.recipeImage = imageURL
                self.firRecipeRef.updateChildValues(["recipeImage": imageURL])
                ProgressHUD.showSuccess("Success")
                
            }, onError: { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            })
        })
 
    }
}
extension RecipeDetailsVC:UITableViewDelegate, UITableViewDataSource{
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

extension RecipeDetailsVC: UIScrollViewDelegate {
    
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
                //print("current location: \(currentLocation)")
                if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
                    //print("up")
                    if currentLocation <= -20 {
                        moveTabDetailContainerViewsDown()
                    }
                }
                else {
                    //print("down")
                    moveTabDetailContainerViewsUp()
                }
            }
        }
    }
}
