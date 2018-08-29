//
//  LoginVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/20.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import MaterialTextField

class LoginVC: UIViewController {
    var tfEmail: MFTextField!
    var tfPassword: MFTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       addTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onLogin(_ sender: Any) {
        var bRegisterable = true
        if (tfEmail.text?.isEmpty)! {
            bRegisterable = false
            tfEmail.setError(errorWithLocalizedDescription(localizedDescription: "Email can't be empty"), animated: true)
        }

        if (tfPassword.text?.isEmpty)! {
            bRegisterable = false
            tfPassword.setError(errorWithLocalizedDescription(localizedDescription: "Password can't be empty"), animated: true)
        }
        
        if bRegisterable{
            logInwithEmail(email: tfEmail.text!, password: tfPassword.text!)
        }
    }
    
    func logInwithEmail(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                let alert = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                alert.addAction(defaultAction)
                
                self.present(alert, animated: true, completion: nil)
            }else{
                print("You have successfully logged in")
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onFBLogin(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager.init()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if (error != nil){
                print("Failed to login: " + (error?.localizedDescription)!)
                return
            }
            
            if let accessToken = FBSDKAccessToken.current(){
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if error != nil{
                        print("Login error: " + (error?.localizedDescription)!)
                        
                        let alert = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(defaultAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        print("You have successfully Facebook logged in")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
}

extension LoginVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLogin")!
        tfEmail = cell.viewWithTag(100) as! MFTextField
        tfPassword = cell.viewWithTag(101) as! MFTextField
        
        tfEmail.text = "rb@smartypans.io"
        tfPassword.text = "qwertyuiop"
        return cell
    }
}



extension LoginVC:UITextFieldDelegate{
    
}
