//
//  User.swift
//  Smartypans
//
//  Created by Lucky on 1/28/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
class SUser {
    var email: String?
    var profileImageUrl: String?
    var bgImageUrl: String?
    var name: String?
    var website: String?
    var about: String?
    var id: String?
    //var isFollowing: Bool?
}

extension SUser {
    static func transformUser(dict: [String: Any], key: String) -> SUser {
        let user = SUser()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["imageURL"] as? String
        user.bgImageUrl = dict["bgImage"] as? String
        user.name = dict["name"] as? String
        user.website = dict["website"] as? String
        user.about = dict["about"] as? String
        user.id = key
        return user
    }
}
