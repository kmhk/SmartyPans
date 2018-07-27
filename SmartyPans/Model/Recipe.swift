//
//  Recipe.swift
//  Smartypans
//
//  Created by Lucky on 03/06/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Recipe{
    var recipeId = ""
    var description = ""
    var name = ""
    var recipeImage = ""
    var uid = ""
    var creator = ""
    var creatorImage = ""
    var calories = 0.0
    var cookTime = 0.0
    
    var key = ""
    var ref: DatabaseReference?
    
    
    init(_ snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary?
        
        //let recipeId = dictionaryNutrition["recipeId"] as? String ?? ""
        recipeId = value!!["recipeId"] as? String ?? ""
        description = value!!["description"] as? String ?? ""
        name = value!!["name"] as? String ?? ""
        recipeImage = value!!["recipeImage"] as? String ?? ""
        uid = value!!["uid"] as? String ?? ""
        creator = value!!["creator"] as? String ?? ""
        creatorImage = value!!["creatorImage"] as? String ?? ""
        calories = value!!["calories"] as? Double ?? 0.0
        cookTime = value!!["cookTime"] as? Double ?? 0.0
        
        key = snapshot.key
        ref = snapshot.ref
    }
    
    func toObject() -> [AnyHashable: Any] {
        return ["recipeId": recipeId,
                "description": description,
                "name": name,
                "recipeImage": recipeImage,
                "uid": uid,
                "creator": creator,
                "creatorImage": creatorImage]
    }
}
