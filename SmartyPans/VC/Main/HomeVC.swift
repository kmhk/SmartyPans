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
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewSearchContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categoryCollectionView: UICollectionView?
    
    var recipes = [Recipe]()
    var user: SPUser!
    var firRecipesRef : DatabaseReference!
    var firUser: User?
    var firUserRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 40
        if #available(iOS 11.0, *) {
            tableView.layer.maskedCorners = [.layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        viewSearchContainer.clipsToBounds = true
        viewSearchContainer.layer.cornerRadius = viewSearchContainer.frame.size.height / 2
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        categoryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 90), collectionViewLayout: layout)
        categoryCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryCollectionView?.dataSource = self
        categoryCollectionView?.delegate = self
        categoryCollectionView?.backgroundColor = UIColor.white
        tableView.tableHeaderView = categoryCollectionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHandle() 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        var rt = viewSearchContainer.frame
//        rt.origin.x = self.view.frame.size.width - 50
//        rt.origin.y = 40
//        self.viewSearchContainer.frame = rt
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
            self.tableView.reloadData()
            self.categoryCollectionView?.reloadData()
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
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            var rt = self.viewSearchContainer.frame
            rt.origin.x = -50
            self.viewSearchContainer.frame = rt
        }) { (flag) in
            self.searchBar.becomeFirstResponder()
        }
    }
    
    @objc func saveRecipe(sender: Any) {
        let index = (sender as! UIButton).tag
        let recipe = recipes[index]
        firRecipesRef = Database.database().reference(withPath: "user-recipes")
        firRecipesRef.child(firUser!.uid).child(recipe.recipeId).setValue(recipe.toObject())
        
        // show animation alert
        let string = NSAttributedString(string: "Saved To Recipe Book",
                                        attributes: [NSAttributedString.Key.font: UIFont(name: "NunitoSans-Bold", size: 16.0)!,
                                                     NSAttributedString.Key.foregroundColor: UIColor.black])
        NotificationView.showNotification(parent: self, imageURL: recipe.recipeImage, string: string)
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


extension HomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5, animations: {
            var rt = self.viewSearchContainer.frame
            rt.origin.x = self.view.frame.size.width - 50
            self.viewSearchContainer.frame = rt
        }) { (flag) in
            
        }
    }
}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRecipeTVCell") as! HomeRecipeTVCell
        
        let recipe = recipes[indexPath.row]
        cell.nameLabel.text = recipe.name
        cell.creatorLabel.text = recipe.creator
        cell.creatorImage.sd_setImage(with: URL(string: recipe.creatorImage), completed: nil)
        cell.recipeImage.sd_setImage(with: URL(string: recipe.recipeImage), completed: nil)
        cell.saveBtn.addTarget(self, action: #selector(saveRecipe(sender:)), for: .touchUpInside)
        cell.saveBtn.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recipe = recipes[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "StepByStep", bundle: nil)
        let sbsCompletedController = storyBoard.instantiateViewController(withIdentifier: "StepByStepViewController") as! StepByStepViewController
        
        sbsCompletedController.recipeId = recipe.recipeId
        
        let navVC: UINavigationController = UINavigationController(rootViewController: sbsCompletedController)
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
    }
}


extension HomeVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryCollectionView {
            return 10
        }
        
        return (recipes.count > 0 ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            
            var imgView: UIImageView? = cell.viewWithTag(100) as? UIImageView
            if imgView == nil {
                imgView = UIImageView(frame: CGRect(x: 20, y: 25, width: 50, height: 50))
                imgView?.layer.cornerRadius = (imgView?.frame.size.width)! / 2
                imgView?.clipsToBounds = true
                imgView?.contentMode = .scaleAspectFill
                imgView?.tag = 100
                cell.addSubview(imgView!)
            }
            
            imgView!.image = UIImage(named: "bg_welcome")
            
            var lbl: UILabel? = cell.viewWithTag(200) as? UILabel
            if lbl == nil {
                lbl = UILabel(frame: CGRect(x: 0, y: 75, width: 90, height: 15))
                lbl?.font = UIFont(name: "NunitoSans-Bold", size: 13)
                lbl?.textAlignment = .center
                lbl?.tag = 200
                lbl?.textColor = UIColor.black
                cell.addSubview(lbl!)
            }
            
            lbl?.text = "All recipes"
            
//            cell.layer.borderWidth = 1.0
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDailyCVCell", for: indexPath) as! HomeDailyCVCell
        
        let recipe = recipes[0]
        cell.nameLabel.text = recipe.name
        cell.creatorLabel.text = "Recipe of the Day by " + recipe.creator
        cell.creatorImage.sd_setImage(with: URL(string: recipe.creatorImage), completed: nil)
        cell.recipeImage.sd_setImage(with: URL(string: recipe.recipeImage), completed: nil)
        cell.saveBtn.addTarget(self, action: #selector(saveRecipe(sender:)), for: .touchUpInside)
        cell.saveBtn.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.categoryCollectionView {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        }
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.categoryCollectionView {
            return CGSize(width: 90, height: 90)
        }
        //let screenWidth = UIScreen.main.bounds.size.width
        //let width = screenWidth
        //let height = CGFloat(225)
        
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoryCollectionView {
            return
        }
        
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
