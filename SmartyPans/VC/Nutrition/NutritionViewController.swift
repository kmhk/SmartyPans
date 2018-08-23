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

class NutritionViewController: UIViewController {
    @IBOutlet weak var nav_Vw: UIView!
    @IBOutlet var pieChartLeft: XYPieChart!
    @IBOutlet var view_circal: UIView!
    @IBOutlet weak var lbe_Dot: UILabel!
    
    
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
    
    var databaseReference: DatabaseReference?
    @objc public var recipeId: String = ""
    @objc public var recipeImageURL: String = ""
    let apiURL = "http://api-test.smartypans.io/v1/nutrition/solo_ingredient"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initGradient()
        setRecipeImage()
        databaseReference = Database.database().reference()
        getNutritionInformation()
        
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
        var nutritionObject = Nutrition(cholestrol: 0.0, calories: 0.0, sugar: 0.0, protein: 0.0, saturatedFat: 0.0, totalFat: 0.0, carbohydrates: 0.0, sodium: 0.0, recipeId: "")
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
    }
    
    func initGradient(){
        let gradient = CAGradientLayer()
        let topColor: UIColor? = UIColor(red: 42.0 / 255.0, green: 53.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        let bottomColor: UIColor? = UIColor(red: 226.0 / 255.0, green: 35.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 64.0)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [(topColor?.cgColor as? Any), (bottomColor?.cgColor as? Any)]
        nav_Vw.layer.insertSublayer(gradient, at: 0)
    }
    
    //MARK: Set recipe image from URL
    func setRecipeImage(){
        recipeImage.layer.borderWidth = 1
        recipeImage.layer.masksToBounds = false
        recipeImage.layer.borderColor = UIColor.black.cgColor
        recipeImage.layer.cornerRadius = recipeImage.frame.height/2
        recipeImage.clipsToBounds = true
        
        //TODO descomentar
//        Alamofire.request(recipeImageURL).responseData { response in
//            if let image = response.result.value {
//                self.recipeImage.image = UIImage(data: image)
//            }
//        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}


