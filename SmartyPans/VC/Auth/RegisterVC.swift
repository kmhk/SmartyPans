//
//  RegisterVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/20.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MaterialTextField

class RegisterVC: UIViewController {
    var tfEmail: MFTextField!
    var tfUsername: MFTextField!
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
    @IBAction func onRegister(_ sender: Any) {
        var bRegisterable = true
        
        if (tfEmail.text?.isEmpty)! {
            bRegisterable = false
            tfEmail.setError(errorWithLocalizedDescription(localizedDescription: "Email can't be empty"), animated: true)
        }
        /*if (tfUsername.text?.isEmpty)! {
            bRegisterable = false
            tfUsername.setError(errorWithLocalizedDescription(localizedDescription: "Username can't be empty"), animated: true)
        }*/
        if (tfPassword.text?.isEmpty)! {
            bRegisterable = false
            tfPassword.setError(errorWithLocalizedDescription(localizedDescription: "Password can't be empty"), animated: true)
        }
        
        if bRegisterable{
            signUpwithEmail(email: tfEmail.text!, password: tfPassword.text!)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func signUpwithEmail(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                let alert = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
                alert.addAction(defaultAction)
                
                self.present(alert, animated: true, completion: nil)
            }else{
                print("You have successfully signed up")
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}

extension RegisterVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRegister")!
        tfEmail = cell.viewWithTag(100) as! MFTextField
        tfUsername = cell.viewWithTag(101) as! MFTextField
        tfPassword = cell.viewWithTag(102) as! MFTextField
        return cell
    }
}

extension RegisterVC:UITextFieldDelegate{
    
}

