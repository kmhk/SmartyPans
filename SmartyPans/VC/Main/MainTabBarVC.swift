//
//  MainTabBarVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/19.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !g_bStarted {
            g_bStarted = true
            loadLogin(animate: true)
        }
    }
    
    func loadLogin(animate: Bool){
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateInitialViewController()
        vc?.modalTransitionStyle = .crossDissolve
        parent?.present(vc!, animated: animate, completion: nil)
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
        if index == 1{
            return false
        }
        
        return true
    }
}
