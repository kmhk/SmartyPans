//
//  AuthService.swift
//  Smartypans
//
//  Created by Lucky on 1/28/18.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class AuthService {
    static func updateUserInfor(name: String, website: String, about: String, imageUrl: String, bgImgUrl: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        self.updateDatabase(profileImageUrl: imageUrl, bgImageUrl: bgImgUrl, name: name, website: website, about: about, onSuccess: onSuccess, onError:onError)
        
        /*storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                return
            }
            let profileImageUrl = metadata?.downloadURL()?.absoluteString
            
            let storageRefBG = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child("bgImage").child(uid!)
            
            storageRefBG.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                let bgImageUrl = metadata?.downloadURL()?.absoluteString
                
            })
        })*/
    }
    static func updateDatabase(profileImageUrl: String, bgImageUrl: String, name: String, website: String, about:String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["name": name, "imageURL": profileImageUrl, "bgImage": bgImageUrl, "website": website, "about": about]
        Api.SUser.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
            
        })
    }
    
    static func uploadProfileImage(imageData:Data, isProfile:Bool, onSuccess: @escaping (_ imageUrl: String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void){
        let uid = Api.SUser.CURRENT_USER?.uid
        var sData = "profileImage"
        if !isProfile {
            sData = "bgImage"
        }
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOF_REF).child(sData).child(uid!)
        
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
            /*if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                onSuccess(profileImageUrl)
            }*/
        })
        
    }
}

