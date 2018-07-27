//
//  Nutrition.swift
//  Smartypans
//
//  Created by Rahul Baxi on 1/18/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit

class Nutrition{

    var cholestrol: Double
    var calories: Double
    var sugar: Double
    var protein: Double
    var saturatedFat: Double
    var totalFat: Double
    var carbohydrates: Double
//    var dietaryFiber: Double
    var sodium: Double
    var ingredientImage: String
    var recipeId: String

    init(cholestrol: Double, calories: Double, sugar: Double, protein: Double, saturatedFat: Double, totalFat: Double, carbohydrates: Double,  sodium: Double, recipeId: String){
        self.cholestrol = cholestrol
        self.calories = calories
        self.sugar = sugar
        self.protein = protein
        self.saturatedFat = saturatedFat
        self.totalFat = totalFat
        self.carbohydrates = carbohydrates
//        self.dietaryFiber = dietaryFiber
        self.sodium = sodium
        self.ingredientImage = ""
        self.recipeId = recipeId
    }
    
    static func fromJSON(json: [String: AnyObject]) -> Nutrition{
        return Nutrition(cholestrol: json["cholestrol"] as? Double ?? 0.0,
                         calories: json["calories"] as? Double ?? 0.0,
                         sugar: json["sugar"] as? Double ?? 0.0,
                         protein: json["protein"] as? Double ?? 0.0,
                         saturatedFat: json["saturated_fat"] as? Double ?? 0.0,
                         totalFat: json["total_fat"] as? Double ?? 0.0,
                         carbohydrates: json["carbohydrates"] as? Double ?? 0.0,
                         sodium: json["sodium"] as? Double ?? 0.0, recipeId: "")
    }
    
    func toObject() -> [AnyHashable: Any] {
        return ["cholestrol": cholestrol, "calories": calories, "sugar": sugar, "protein": protein, "saturatedFat": saturatedFat, "totalFat": totalFat, "carbohydrates": carbohydrates, "sodium": sodium]
    }
}

