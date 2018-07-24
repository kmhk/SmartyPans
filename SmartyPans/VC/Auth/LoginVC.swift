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

class LoginVC: UIViewController {

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
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onFBLogin(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager.init()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            print(result.debugDescription)
            if (error != nil){
                print("Failed to login: " + (error?.localizedDescription)!)
            }
            
            if let accessToken = FBSDKAccessToken.current(){
                let credential = FacebookAuthProvider.credential(withAccessToken: (accessToken.tokenString)!)
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
        return cell
    }
}

extension LoginVC:UITextFieldDelegate{
    
}
