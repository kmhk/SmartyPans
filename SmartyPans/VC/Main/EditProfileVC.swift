//
//  EditProfileVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/24.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage
import ProgressHUD

class EditProfileVC: UIViewController {
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPW: UITextField!
    
    var sProfileImageUrl : String = ""
    var sBGImageUrl : String = ""
    var REF_USERS = Database.database().reference().child("users")
    var isProfilePhoto = false
    var picker:UIImagePickerController?=UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRound(toView: imgProfile, radius: 64)
        imgProfile.layer.borderWidth = 8
        imgProfile.layer.borderColor = UIColor.white.cgColor
        
        picker?.delegate = self
        fetchCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchCurrentUser(){
        Api.SUser.observeCurrentUser { (user) in
//            self.txtName.text = user.name
//            self.txtWebsite.text = user.website
//            self.txtDescription.text = user.about
            
            if(user.profileImageUrl != nil)
            {
                self.sProfileImageUrl = user.profileImageUrl!
                if let profileUrl = URL(string: user.profileImageUrl!) {
                    self.imgProfile.sd_setImage(with: profileUrl, placeholderImage: UIImage.init(named: "user"), options: SDWebImageOptions.continueInBackground, completed: nil)
                }
            }
            
            if(user.bgImageUrl != nil)
            {
                self.sBGImageUrl = user.bgImageUrl!
                if let bgUrl = URL(string: user.bgImageUrl!) {
                    self.imgHeader.sd_setImage(with: bgUrl)
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onEditProfilePhoto(_ sender: Any) {
        isProfilePhoto = true
        openSheet()
    }
    
    @IBAction func onEditHeaderPhoto(_ sender: Any) {
        isProfilePhoto = false
        openSheet()
    }
    
    func openSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            self.openCamera()
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Photo Gallery", style: .default)
        { _ in
            self.openGallary()
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func openGallary()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Photo Gallery Error", message: "Can't access to Photo Gallery", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
    {
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func onDone(_ sender: Any) {
        //ProgressHUD.show("Waiting...")
        
        /*AuthService.updateUserInfor(name: txtName.text!, website: txtWebsite.text!, about: txtDescription.text, imageUrl: sProfileImageUrl, bgImgUrl: sBGImageUrl, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.delegate?.updateUserInfor()
            self.dismiss(animated: true, completion: nil)
        }, onError: { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        })*/
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        if isProfilePhoto{
            imgProfile.image = chosenImage
        }else{
            imgHeader.image = chosenImage
        }
        let imageData = UIImageJPEGRepresentation(chosenImage, 0.1)
        //imageView.contentMode = .ScaleAspectFit
        //imageView.image = chosenImage
        dismiss(animated: true, completion: {
            ProgressHUD.show("Uploading...")
            AuthService.uploadProfileImage(imageData: imageData!, isProfile: self.isProfilePhoto, onSuccess: { (imageURL) in
                if self.isProfilePhoto{
                    self.sProfileImageUrl = imageURL
                }else{
                    self.sBGImageUrl = imageURL
                }
                ProgressHUD.showSuccess("Success")
                
            }, onError: { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            })
        })
    }
}
