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
        
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "tab_add")
        btn.setImage(img, for: .normal)
        btn.bounds = CGRect(x: 0, y: 0, width: (img?.size.width)!, height: (img?.size.height)!)
        btn.addTarget(self, action: #selector(btnCenterTapped(sender:)), for: .touchUpInside)
        tabBar.addSubview(btn)
        
        let rectBoundTabbar = self.tabBar.bounds
        let xx = rectBoundTabbar.midX
        let yy = rectBoundTabbar.midY - 10
        btn.center = CGPoint(x: xx, y: yy)
        
//        UIImage *image = [UIImage imageNamed:@"buttonImage.png"];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
//        [button setImage:image forState:UIControlStateNormal];
//        [button addTarget:myTarget action:@selector(myAction) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
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
    
    @objc func btnCenterTapped(sender: Any) {
        let panPairStory: UIStoryboard = UIStoryboard(name: "PanPair", bundle: nil)
        let vc = panPairStory.instantiateInitialViewController()
        navigationController?.pushViewController(vc!, animated: true)
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
        if index == 2{
            btnCenterTapped(sender: self)
            //let panPairStory: UIStoryboard = UIStoryboard(name: "PanPair", bundle: nil)
            //let vc = panPairStory.instantiateInitialViewController()
            //let vc = storyboard?.instantiateViewController(withIdentifier: "PanPairVC")
//            navigationController?.show(vc, sender: nil)
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Recipe", bundle: nil)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "AddIngredientVC") as! AddIngredientViewController
            //navigationController?.present(vc!, animated: true, completion: nil)
            //navigationController?.pushViewController(vc!, animated: true)
            
//            let navVC: UINavigationController = UINavigationController(rootViewController: vc!)
//            navVC.navigationBar.isHidden = true
//            navigationController?.present(navVC, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}
