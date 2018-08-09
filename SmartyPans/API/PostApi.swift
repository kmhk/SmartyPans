//
//  PostApi.swift
//  Smartypans
//
//  Created by Lucky on 1/29/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

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
    
    static func uploadRecipeImage(imageData:Data, recipeId: String, onSuccess: @escaping (_ imageUrl: String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void){
        
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("recipes/" + recipeId + ".jpg")
        
        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if(error != nil){
                    onError(error?.localizedDescription);
                }else{
                    onSuccess((url?.absoluteString)!)
                }
            })
            
        })
        
    }
}
