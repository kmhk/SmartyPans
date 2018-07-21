//
//  PostApi.swift
//  Smartypans
//
//  Created by Lucky on 1/29/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase
class PostApi {
    var REF_POSTS = Database.database().reference().child("recipes")
    
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformRecipe(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
}
