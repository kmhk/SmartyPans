//
//  NutritionViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/22/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AYPieChart
import DYPieChartView

class NutritionViewController: UIViewController {

    @IBOutlet weak var viewPieContainer: UIView!
    @IBOutlet weak var pieChartView: DYPieChartView!
    
    @IBOutlet var view_circal: UIView!
    
    @IBOutlet weak var lbe_Dot: UILabel!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var labelProteins: UILabel!
    @IBOutlet weak var labelCarbs: UILabel!
    @IBOutlet weak var labelFat: UILabel!
    
    @IBOutlet weak var labelCalories: UILabel!
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var labelSodium: UILabel!
    @IBOutlet weak var labelCholestrol: UILabel!
    @IBOutlet weak var labelSugar: UILabel!
    @IBOutlet weak var labelSaturatedFat: UILabel!
    @IBOutlet weak var labelTotalFat: UILabel!
    
    @IBOutlet weak var lblRecipeTitle: UILabel!
    
    var databaseReference: DatabaseReference?
    @objc public var recipeId: String = ""
    @objc public var recipeImageURL: String = ""
    let apiURL = "http://api-test.smartypans.io/v1/nutrition/solo_ingredient"
    
    //let pieColors: [UIColor] = [hexStringToUIColor(hex: "912B6D"), hexStringToUIColor(hex: "D7225D"), hexStringToUIColor(hex: "2C3277")]
    let pieColors: [UIColor] = [UIColor(red:0.98, green:0.78, blue:0.42, alpha:1),
                                UIColor(red:0.54, green:0.58, blue:0.98, alpha:1),
                                UIColor(red:0.89, green:0.14, blue:0.27, alpha:1)]
    var pieValues: [CGFloat] = [0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRecipeImage()
        databaseReference = Database.database().reference()
        getNutritionInformation()
        
        viewContainer.layer.cornerRadius = 20
        viewContainer.clipsToBounds = true
        if #available(iOS 11.0, *) {
            viewContainer.layer.maskedCorners = [.layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 642)
        
        view_circal.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        setupPieChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Get Nutrition Data from Cloud
    /*
     Checks if the recipe already has a nutrition object and retrieve it to populate the UI.
     If the recipe does not have a nutrition object yet, retrieves raw data from the
     SmartyPans API, creates the nutrition object and saves it to the database.
     */
    
    func setupPieChart() {
        pieChartView.startAngle = CGFloat(-Double.pi / 2)
        pieChartView.clockwise = true
        pieChartView.lineWidth = 32
        pieChartView.sectorColors = pieColors
        
        pieChartView.animate(toScaleValues: [0.6, 0.14, 0.26], duration: 2)
        pieChartView.scaleValues = [0.6, 0.14, 0.26]
    }
    
    func getNutritionInformation(){
        print("Recipe Id from RecipeDetailsViewController: \(self.recipeId)")
        databaseReference?.child("recipe-nutrition").child(self.recipeId).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary?
            if value == nil {
                self.createNutritionInformation()
            }else{
                self.convertNutritionFromNSDictionary(dictionaryNutrition: value!!)
            }
        }){(error) in
            print(error.localizedDescription)
        }
        
    }
    
    func convertNutritionFromNSDictionary(dictionaryNutrition: NSDictionary){
        let protein = dictionaryNutrition["protein"] as? Double ?? 0.0
        let carbohydrates = dictionaryNutrition["total_carbohydrate"] as? Double ?? 0.0
        let calories = dictionaryNutrition["calories"] as? Double ?? 0.0
        let totalFat = dictionaryNutrition["total_fat"] as? Double ?? 0.0
        let saturatedFat = dictionaryNutrition["saturated_fat"] as? Double ?? 0.0
        let sugar = dictionaryNutrition["sugar"] as? Double ?? 0.0
        let cholestrol = dictionaryNutrition["cholestrol"] as? Double ?? 0.0
        let sodium = dictionaryNutrition["sodium"] as? Double ?? 0.0
        let recipeId = dictionaryNutrition["recipeId"] as? String ?? ""
        
        let nutritionInfo = Nutrition(cholestrol: cholestrol, calories: calories, sugar: sugar, protein: protein, saturatedFat: saturatedFat, totalFat: totalFat, carbohydrates: carbohydrates, sodium: sodium, recipeId: recipeId)
        
        populateNutritionInformation(nutrition: nutritionInfo)
    }
    
    func createNutritionInformation(){
        SVProgressHUD.showInfo(withStatus: "Computing Nutrition Information")
        var steps: [RecipeStep] = []
        databaseReference?.child("recipe-steps").child(self.recipeId).observeSingleEvent(of: .value, with: { (snapshot) in
            for item in snapshot.children{
                let step = RecipeStep(item as! DataSnapshot)
                steps.append(step)
            }
            let nutrition = self.computeNutrition(steps: steps)
            self.populateNutritionInformation(nutrition: nutrition)
            SVProgressHUD.dismiss()
            self.databaseReference?.child("recipe-nutrition").child(self.recipeId).setValue(nutrition.toObject())
        }){(error) in
            print(error.localizedDescription)
        }
    }
    
    func computeNutrition(steps: [RecipeStep]) -> Nutrition{
        let nutritionObject = Nutrition(cholestrol: 0.0, calories: 0.0, sugar: 0.0, protein: 0.0, saturatedFat: 0.0, totalFat: 0.0, carbohydrates: 0.0, sodium: 0.0, recipeId: "")
        for step in steps{
            let params = ["query": "\(step.weight) oz \(step.ingredient)"] as Dictionary<String, String>
            
            var request = URLRequest(url: URL(string: "http://api-test.smartypans.io/v1/nutrition/solo_ingredient")!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    DispatchQueue.global().async {
                        let nutrition = Nutrition.fromJSON(json: json)
                        nutritionObject.cholestrol += nutrition.cholestrol
                        nutritionObject.calories += nutrition.calories
                        nutritionObject.sugar += nutrition.sugar
                        nutritionObject.totalFat += nutrition.totalFat
                        nutritionObject.saturatedFat += nutrition.saturatedFat
                        nutritionObject.carbohydrates += nutrition.carbohydrates
                        nutritionObject.sodium += nutrition.sodium
                        
                    }
                } catch {
                    print("error")
                }
            })
            task.resume()
            
        }
        return nutritionObject
    }
    
    func populateNutritionInformation(nutrition: Nutrition){
        labelProteins.text = "\(nutrition.protein.format(f: ".2")) g"
        labelCarbs.text = "\(nutrition.carbohydrates.format(f: ".2")) g"
        labelFat.text = "\(nutrition.totalFat.format(f: ".2")) g"
        
        labelCalories.text = "\(nutrition.calories.format(f: ".2")) C"
        labelTotalFat.text = "\(nutrition.totalFat.format(f: ".2")) g"
        labelSaturatedFat.text = "\(nutrition.saturatedFat.format(f: ".2")) g"
        labelSugar.text = "\(nutrition.sugar.format(f: ".2")) g"
        labelCholestrol.text = "\(nutrition.cholestrol.format(f: ".2")) g"
        labelSodium.text = "\(nutrition.sodium.format(f: ".2")) g"
        
        pieValues = [CGFloat(nutrition.protein), CGFloat(nutrition.carbohydrates), CGFloat(nutrition.totalFat)]
        //setupPieChart()
    }
    
    
    //MARK: Set recipe image from URL
    func setRecipeImage(){
        recipeImage.sd_setImage(with: URL(string: recipeImageURL)!, completed: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension NutritionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) { // up scroll
            UIView.animate(withDuration: 0.5) {
                self.viewContainer.frame = CGRect(x: 0, y: 170, width: self.viewContainer.frame.width, height: self.view.frame.height - 170)
                
                self.view_circal.alpha = 0.0
                self.view_circal.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 170)
                
                self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (self.view.frame.size.height > 670 ? self.view.frame.size.height + 20 : 670))
                
                self.lblRecipeTitle.frame = CGRect(x: 22, y: 122, width: self.lblRecipeTitle.frame.size.width, height: self.lblRecipeTitle.frame.size.height)
            }
        } else { // down scroll
            UIView.animate(withDuration: 0.5) {
                self.viewContainer.frame = CGRect(x: 0, y: 0, width: self.viewContainer.frame.width, height: self.view.frame.height)
                
                self.view_circal.alpha = 1.0
                self.view_circal.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
                
                self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (self.view.frame.size.height > 670 ? self.view.frame.size.height + 20 : 670))
                
                self.lblRecipeTitle.frame = CGRect(x: 60, y: 29, width: self.lblRecipeTitle.frame.size.width, height: self.lblRecipeTitle.frame.size.height)
            }
        }
    }
}
