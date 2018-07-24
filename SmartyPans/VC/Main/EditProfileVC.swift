//
//  EditProfileVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/24.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPW: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRound(toView: imgProfile, radius: 64)
        imgProfile.layer.borderWidth = 8
        imgProfile.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
