//
//  WelcomeVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/19.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        setRound(toView: btnRegister, radius: 25)
        setRound(toView: btnLogin, radius: 25)
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
