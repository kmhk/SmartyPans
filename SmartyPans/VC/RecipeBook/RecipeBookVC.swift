//
//  RecipeBookVC.swift
//  SmartyPans
//
//  Created by com on 6/20/2019.
//  Copyright © KMHK. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class RecipeBookVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    //var searchBar: UISearchBar?
    @IBOutlet weak var searchBar: UISearchBar!
    
    var savedCollectionView: UICollectionView?
    
    var recipes = [Recipe]()
    var collections = [String]()
    var firRecipesRef : DatabaseReference!
    var firUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 56))
//        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 50))
//        searchBar?.barTintColor = UIColor(red: 244, green: 244, blue: 244, av: 1.0)
//        searchBar?.isTranslucent = false
//        searchBar?.placeholder = "Search"
//        searchView.addSubview(searchBar!)
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = self.view.backgroundColor?.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getRecipes()
        getCollections()
    }
    
    func getRecipes() {
        firUser = Api.SUser.CURRENT_USER
        firRecipesRef = Database.database().reference(withPath: "user-recipes").child(firUser!.uid)
        firRecipesRef.observe(.value) { (snapshot) in
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
    }
    
    func getCollections() {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid)
        firRecipesRef.observe(.value) { (snapshot) in
            var newItems = [String]()
            for item in snapshot.children {
                let str = (item as! DataSnapshot).key as String
                newItems.append(str)
            }
            
            self.collections = newItems
            self.savedCollectionView?.reloadData()
        }
    }
    
    func saveNewCollection(name: String) {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid).child(name)
        firRecipesRef.setValue("")
    }
    
    func addRecipeToCollection(recipe: Recipe, collection: String) {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid).child(collection)
        firRecipesRef.child(recipe.recipeId).setValue(recipe.toObject())
    }
    
    func unsaveRecipe(recipeID: String) {
        firRecipesRef = Database.database().reference(withPath: "user-recipes").child(firUser!.uid)
        firRecipesRef.child(recipeID).setValue(nil)
    }
    
    @objc func addToCollection(sender: Any) {
        let tag = (sender as! UIButton).tag
        let recipe = recipes[tag]
        
        let v = RBActionSheetView.show(parent: self.parent!,
                               title: "Recipe",
                               images: [UIImage(named: "icoAdd")!, UIImage(named: "icoDelete")!],
                               btnNames: ["Add To Collection", "Unsave"],
                               flag: true,
                               handler: { (index) in
                                
                                var imgs: [UIImage] = [UIImage]()
                                self.collections.map { _ in
                                    imgs.append(UIImage(named: "bg_welcome")!) // need to be add colection image
                                }
                                
                                if (index == 0) { // add
                                    RBActionSheetView.show(parent: self.parent!,
                                                           title: "Add To Collection",
                                                           images: imgs,
                                                           btnNames: self.collections,
                                                           flag: false, handler: { (index) in
                                                            
                                                            self.addRecipeToCollection(recipe: recipe, collection: self.collections[index])
                                    })
                                    
                                } else { // remove
                                    self.unsaveRecipe(recipeID: recipe.recipeId)
                                }
        })
        
        v.shareHandler = {
            let vc = UIActivityViewController(activityItems: ["more"], applicationActivities: nil)
            vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard,
                                        .message, .mail, .openInIBooks, .print, .saveToCameraRoll]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func addNewCollection(sender: Any) {
        RBAlertView.showWithTextField(parent: self, title: "NAME YOUR COLLECTION", value: "") { (name) in
            self.saveNewCollection(name: name)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - UICollectionView

extension RecipeBookVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == savedCollectionView {
            return 1
        }
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == savedCollectionView {
            return self.collections.count + 1
        }
        
        if section == 0 { // always return 1 for collected list
            return 1
        }
        
        return self.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if collectionView == savedCollectionView {
//            let header = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//            return header
//        }
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RBCollectionRegularHV", for: indexPath)
            for subView in headerView.subviews {
                subView.removeFromSuperview()
            }
            
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 20, height: headerView.frame.size.height))
            label.font = UIFont(name: "NunitoSans-Bold", size: 22)
            label.textColor = UIColor.black
            label.tag = 100
            headerView.addSubview(label)
            
            if indexPath.section == 0 {
                label.text = "Collections"
                
                let btnAdd = UIButton(frame: CGRect(x: headerView.frame.size.width - 50, y: 15, width: 30, height: 30))
                btnAdd.setImage(UIImage(named: "btnNewCollection"), for: .normal)
                btnAdd.addTarget(self, action: #selector(addNewCollection(sender:)), for: .touchUpInside)
                headerView.addSubview(btnAdd)
            } else {
                label.text = "Saved Items"
            }
            
            return headerView
        }
        
        let header = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == savedCollectionView {
            return CGSize(width: 145, height: 100)
        }
        
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.size.width, height: 100)
        } else {
            let w = collectionView.frame.size.width / 2 - 11
            return CGSize(width: w, height: 225)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == savedCollectionView { // colletion list
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RBCollectedCVCell", for: indexPath)
            
            var recipeImageView = cell.viewWithTag(100) as? UIImageView
            if recipeImageView == nil {
                recipeImageView = UIImageView(frame: cell.bounds)
                recipeImageView?.contentMode = .scaleAspectFill
                recipeImageView?.layer.cornerRadius = 4
                recipeImageView?.clipsToBounds = true
                recipeImageView?.tag = 100
                cell.addSubview(recipeImageView!)
            }
            
            var titleView = cell.viewWithTag(200) as? UILabel
            if titleView == nil {
                titleView = UILabel(frame: CGRect(x: 10, y: cell.frame.size.height - 20, width: cell.frame.size.width - 20, height: 15))
                titleView?.font = UIFont(name: "NunitoSans-Bold", size: 14)
                titleView?.textColor = UIColor.white
                titleView?.tag = 200
                cell.addSubview(titleView!)
            }
            
            if indexPath.row >= collections.count {
                recipeImageView?.image = UIImage(named: "collectionThumb")
                titleView?.text = ""
            } else {
                recipeImageView?.image = UIImage(named: "bg_welcome")
                titleView?.text = self.collections[indexPath.row]
            }
            
            return cell
        }
        
        if indexPath.section == 0 { // collected container
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RBCollectedBKCell", for: indexPath)
            if savedCollectionView == nil {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                
                savedCollectionView = UICollectionView(frame: cell.bounds, collectionViewLayout: layout)
                savedCollectionView?.dataSource = self
                savedCollectionView?.delegate = self
                savedCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "RBCollectedCVCell")
                savedCollectionView?.backgroundColor = UIColor.clear
                cell.addSubview(savedCollectionView!)
            }
            
            return cell
            
        } else { // saved list
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RBSavedCollectionCell", for: indexPath) as! RBSavedCVCell
            cell.layer.cornerRadius = 4
            cell.clipsToBounds = true
            
            let recipe = recipes[indexPath.row]
            cell.nameLabel.text = recipe.name
            cell.creatorLabel.text = recipe.creator
            cell.creatorImage.sd_setImage(with: URL(string: recipe.creatorImage), completed: nil)
            cell.recipeImage.sd_setImage(with: URL(string: recipe.recipeImage), completed: nil)
            cell.settingBtn.addTarget(self, action: #selector(addToCollection(sender:)), for: .touchUpInside)
            cell.settingBtn.tag = indexPath.row
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == savedCollectionView { // colletion list
            if indexPath.row >= collections.count {
                self.addNewCollection(sender: self)
            } else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "RecipeCollectionVC") as! RecipeCollectionVC
                vc.collectionName = collections[indexPath.row]
                vc.collections = collections
                
                let navVC: UINavigationController = UINavigationController(rootViewController: vc)
                navVC.navigationBar.isHidden = true
                self.present(navVC, animated: true, completion: nil)
            }
            return
        }
        
        if indexPath.section == 1 {
            let recipe = recipes[indexPath.row]
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "StepByStep", bundle: nil)
            let sbsCompletedController = storyBoard.instantiateViewController(withIdentifier: "StepByStepViewController") as! StepByStepViewController
            
            sbsCompletedController.recipeId = recipe.recipeId
            
            let navVC: UINavigationController = UINavigationController(rootViewController: sbsCompletedController)
            navVC.navigationBar.isHidden = true
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
}
