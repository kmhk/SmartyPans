//
//  HomeVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/24.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class HomeVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var recipes = [Recipe]()
    var user: SPUser!
    var firRecipesRef : DatabaseReference!
    var firUser: User?
    var firUserRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addHandle() 
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHandle(){
        print("HomeViewcontroller add handle")
        firUser = Api.SUser.CURRENT_USER
        firRecipesRef = Database.database().reference(withPath: "home_recipes")
        firRecipesRef.queryOrdered(byChild: "name").observe(.value) { (snapshot) in
            var newItems = [Recipe]()
            for item in snapshot.children{
                let recipe = Recipe.init(item as! DataSnapshot)
                newItems.append(recipe)
            }
            
            if newItems.count == 0{
                return
            }
            
            self.recipes = newItems
            self.collectionView.reloadData()
        }
        
        if let firUser = firUser {
            firUserRef = Database.database().reference(withPath: "users").child(firUser.uid)
            
            firUserRef.observe(.value) { (snapshot) in
                if !snapshot.hasChildren(){
                    return
                }
                
                let user = SPUser.init(snapshot)
                self.user = user
            }
        }
    }
    
    @objc func saveRecipe(sender: Any) {
        let index = (sender as! UIButton).tag
        let recipe = recipes[index]
        firRecipesRef = Database.database().reference(withPath: "user-recipes")
        firRecipesRef.child(user.key).child(recipe.recipeId).setValue(recipe.toObject())
        
        // show animation alert
        let waiting = UIView(frame: self.view.bounds)
        waiting.backgroundColor = UIColor.clear
        
        let lbl = UILabel(frame: CGRect(x: waiting.frame.size.width / 2 - 60, y: 30, width: 100, height: 20))
        lbl.text = "Recipe Saved"
        lbl.textColor = UIColor.white
        lbl.font = UIFont(name: "NunitoSans-Regular", size: 12.0)
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor.lightGray
        lbl.layer.cornerRadius = 3
        lbl.clipsToBounds = true
        waiting.addSubview(lbl)
        
        self.view.addSubview(waiting)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            waiting.alpha = 0
        }, completion: { (flag) in
            waiting.removeFromSuperview()
        })
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

extension HomeVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCVCell
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        let recipe = recipes[indexPath.row]
        cell.nameLabel.text = recipe.name
        cell.creatorLabel.text = recipe.creator
        cell.creatorImage.sd_setImage(with: URL(string: recipe.creatorImage), completed: nil)
        cell.recipeImage.sd_setImage(with: URL(string: recipe.recipeImage), completed: nil)
        cell.saveBtn.addTarget(self, action: #selector(saveRecipe(sender:)), for: .touchUpInside)
        cell.saveBtn.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth / 2 - 11
        let height = CGFloat(225)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "StepByStep", bundle: nil)
        let sbsCompletedController = storyBoard.instantiateViewController(withIdentifier: "StepByStepViewController") as! StepByStepViewController
        
        sbsCompletedController.recipeId = recipe.recipeId
        
        let navVC: UINavigationController = UINavigationController(rootViewController: sbsCompletedController)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
        
//        let recipeVC = self.storyboard?.instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsVC
//        recipeVC.recipeId = recipe.recipeId
//        self.present(recipeVC, animated: true, completion: nil)
    }
}
