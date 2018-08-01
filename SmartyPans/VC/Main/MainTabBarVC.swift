//
//  MainTabBarVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/19.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarVC: UITabBarController {
    static var shared : MainTabBarVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        MainTabBarVC.shared = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Api.SUser.CURRENT_USER == nil {
        //if !g_bStarted {
            //g_bStarted = true
            loadLogin(animate: true)
        }
    }
    
    func loadLogin(animate: Bool){
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateInitialViewController()
        vc?.modalTransitionStyle = .crossDissolve
        parent?.present(vc!, animated: animate, completion: nil)
        loadScreen(indexOf: 0)
    }
    func loadScreen(indexOf: Int){
        self.selectedIndex = indexOf
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

extension MainTabBarVC:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.index(of: viewController)!
        //Add Recipe
        if index == 1{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PanPairVC")
            navigationController?.show(vc!, sender: nil)
            return false
        }
        
        return true
    }
}
