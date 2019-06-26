//
//  Step.swift
//  Smartypans
//
//  Created by Rahul Baxi on 1/17/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RecipeStep{
    var uid = ""
    var stepId = ""
    var stepNumber = 0
    var stepDescription = ""
    var ingredient = ""
    var ingredientImage = ""
    var unit = ""
    var weight: Double
    var startTime: Double
    var endTime: Double
    var recipeId = ""
    var key = ""
    var ref: DatabaseReference?
    
    
      init(_ snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary?
        
        //let recipeId = dictionaryNutrition["recipeId"] as? String ?? ""
        uid = value!!["uid"] as? String ?? ""
        stepId = value!!["id"] as? String ?? ""
        stepNumber = value!!["number"] as? Int ?? 0
        stepDescription = value!!["description"] as? String ?? ""
        ingredient = value!!["consistency"] as? String ?? ""
        ingredientImage = value!!["imageThumb"] as? String ?? ""
        unit = value!!["unit"] as? String ?? ""
        weight = value!!["quantity"] as? Double ?? 0.0
        startTime = value!!["startTime"] as? Double ?? 0.0
        endTime = value!!["endTime"] as? Double ?? 0.0
        recipeId = value!!["recipeId"] as? String ?? ""
        
        key = snapshot.key
        ref = snapshot.ref
    }
    
    //Default initializer
    init() {
        ref = nil
        weight = 0.0
        startTime = 0.0
        endTime = 0.0
    }
    func toObject() -> [AnyHashable: Any] {
        return ["id":stepId, "uid": uid, "stepNumber": stepNumber, "description": stepDescription, "ingredient": ingredient, "ingredientPicture": ingredientImage, "unit": unit, "weight": weight, "startTime": startTime, "endTime": endTime, "recipeId": recipeId]
    }
}
