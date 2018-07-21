//
//  UserApi.swift
//  Smartypans
//
//  Created by Lucky on 1/28/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var REF_USERS = Database.database().reference().child("users")
    func observeCurrentUser(completion: @escaping (SUser) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = SUser.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        
        return nil
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
}
