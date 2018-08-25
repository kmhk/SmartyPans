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
    
    let pieColors: [UIColor] = [hexStringToUIColor(hex: "912B6D"), hexStringToUIColor(hex: "D7225D"), hexStringToUIColor(hex: "2C3277")]
    var pieValues: [CGFloat] = [0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func setupPieChart() {
        
        setRound(toView: view_circal, radius: view_circal.bounds.height/2)
        
        //pieChartLeft.delegate = self
        pieChartLeft.dataSource = self
        //pieChartLeft.startPieAngle = M_PI_2//optional
        pieChartLeft.animationSpeed = 1.0//optional
        pieChartLeft.showLabel = false
        //pieChartLeft.labelFont = UIFont(name: "DBLCDTempBlack", size: 24)//optional
        //pieChartLeft.labelColor = UIColor.black//optional, defaults to white
        //pieChartLeft.labelShadowColor = UIColor.black        //optional, defaults to none (nil)
        //pieChartLeft.labelRadius = 160//optional
        pieChartLeft.showPercentage = false//optional
        pieChartLeft.setPieBackgroundColor(.clear)
        pieChartLeft.reloadData()
        //pieChartLeft.pieBackgroundColor = UIColor(white: 0.95, alpha: 1)//optional
        
        //pieChartLeft.pieCenter = CGPoint(x: 240, y: 240)//optional
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
        
        pieValues = [CGFloat(nutrition.protein), CGFloat(nutrition.carbohydrates), CGFloat(nutrition.totalFat)]
        setupPieChart()
    }
    
    
    //MARK: Set recipe image from URL
    func setRecipeImage(){
        recipeImage.layer.borderWidth = 1
        recipeImage.layer.masksToBounds = false
        recipeImage.layer.borderColor = UIColor.black.cgColor
        recipeImage.layer.cornerRadius = recipeImage.frame.height/2
        recipeImage.clipsToBounds = true
        
        print(recipeImageURL)
        
        downloadImage(url: URL(string: recipeImageURL)!)
        
        //TODO descomentar
//        Alamofire.request(recipeImageURL).responseData { response in
//            if let image = response.result.value {
//                self.recipeImage.image = UIImage(data: image)
//            }
//        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.recipeImage.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension NutritionViewController: XYPieChartDataSource {
    
    func numberOfSlices(in pieChart: XYPieChart!) -> UInt {
        return 3
    }
    
    func pieChart(_ pieChart: XYPieChart!, valueForSliceAt index: UInt) -> CGFloat {
        return pieValues[Int(index)]
    }
    
    func pieChart(_ pieChart: XYPieChart!, colorForSliceAt index: UInt) -> UIColor! {
        return pieColors[Int(index)]
    }
    
}

