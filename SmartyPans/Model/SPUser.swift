//
//  SPUser.swift
//  Smartypans
//
//  Created by Lucky on 03/06/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SPUser{
    var imageURL = ""
    var name = ""
    
    var key = ""
    var ref: DatabaseReference?
    
    
    init(_ snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary?
        
        //let recipeId = dictionaryNutrition["recipeId"] as? String ?? ""
        name = value!!["name"] as? String ?? ""
        imageURL = value!!["imageURL"] as? String ?? ""
        
        key = snapshot.key
        ref = snapshot.ref
    }
    
    func toObject() -> [AnyHashable: Any] {
        return ["name": name,
                "imageURL": imageURL]
    }
}
