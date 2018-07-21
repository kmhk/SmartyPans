//
//  Post.swift
//  Smartypans
//
//  Created by Lucky on 1/29/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import FirebaseAuth
class Post {
    var recipeId: String?
    var description: String?
    var name: String?
    var uid: String?
    var creator: String?
    var recipeImage: String?
    var creatorImage: String?
    var calories: String?
    var cookTime: String?
}

extension Post {
    static func transformRecipe(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.recipeId = dict["recipeId"] as? String
        post.uid = dict["uid"] as? String
        post.description = dict["description"] as? String
        post.name = dict["name"] as? String
        post.creator = dict["creator"] as? String
        post.recipeImage = dict["recipeImage"] as? String
        post.creatorImage = dict["creatorImage"] as? String
        post.calories = dict["calories"] as? String
        post.cookTime = dict["cookTime"] as? String
        
        return post
    }
    
    static func transformPostVideo() {
        
    }
}
