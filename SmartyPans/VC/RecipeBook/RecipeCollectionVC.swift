//
//  RecipeCollectionVC.swift
//  SmartyPans
//
//  Created by com on 6/21/19.
//  Copyright © 2019 Lucky. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class RecipeCollectionVC: UIViewController {
    @IBOutlet weak var collectedView: UICollectionView!
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notifyView: UIView!
    @IBOutlet weak var addRecipeBtn: UIButton!
    
    var collectionName: String = ""
    var recipes = [Recipe]()
    var collections = [String]()
    var firRecipesRef : DatabaseReference!
    var firUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addRecipeBtn.layer.cornerRadius = addRecipeBtn.frame.size.height / 2
        addRecipeBtn.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getRecipes()
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
    }
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        RBActionSheetView.show(parent: self, title: self.collectionName,
                               images: [UIImage(named: "icoEdit")!, UIImage(named: "icoDelete")!],
                               btnNames: ["Rename Collection", "Delete Collection"],
                               flag: false) { (index) in
                                
                                if (index == 0) { // rename
                                    RBAlertView.showWithTextField(parent: self, title: "RENAME YOUR COLLECTION", value: self.collectionName) { (name) in
                                        self.updateCollection(name: name)
                                    }
                                } else { // delete
                                    RBAlertView.showAlert(parent: self, title: "DELETE THIS COLLECTION?",
                                                          msg: "This will delete your collection,\nbut its items will still be in your\nsaved list.",
                                                          okTitle: "DELETE", noTitle: "CANCEL", handler: { (result) in
                                                            self.deleteCollection()
                                    })
                                }
        }
    }
    
    @objc func addToCollection(sender: Any) {
        let tag = (sender as! UIButton).tag
        let recipe = recipes[tag]
        
        let v = RBActionSheetView.show(parent: self.parent!,
                               title: "Recipe",
                               images: [UIImage(named: "icoAdd")!, UIImage(named: "icoDelete")!],
                               btnNames: ["Add To Another Collection", "Remove From This Collection"],
                               flag: true) { (index) in
                                
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
                                    self.removeRecipeFromCollection(recipeID: recipe.recipeId)
                                }
        }
        
        v.shareHandler = {
            let vc = UIActivityViewController(activityItems: ["more"], applicationActivities: nil)
            vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard,
                                        .message, .mail, .openInIBooks, .print, .saveToCameraRoll]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func updateCollection(name: String) {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid)
        firRecipesRef.child(collectionName).observeSingleEvent(of: .value) { (snapshot) in
            self.firRecipesRef.child(self.collectionName).setValue(nil)
            self.firRecipesRef.child(name).setValue(snapshot.value)
            
            self.collectionName = name
            self.getRecipes()
        }
    }
    
    func deleteCollection() {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid)
        firRecipesRef.child(collectionName).setValue(nil)
        
        self.backBtnTapped(self)
    }
    
    func addRecipeToCollection(recipe: Recipe, collection: String) {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid).child(collection)
        firRecipesRef.child(recipe.recipeId).setValue(recipe.toObject())
    }
    
    func removeRecipeFromCollection(recipeID: String) {
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid).child(collectionName)
        if recipes.count == 1 {
            firRecipesRef.setValue("")
        } else {
            firRecipesRef.child(recipeID).setValue(nil)
        }
    }
    
    func getRecipes() {
        firUser = Api.SUser.CURRENT_USER
        firRecipesRef = Database.database().reference(withPath: "collections").child(firUser!.uid).child(collectionName)
        firRecipesRef.observe(.value) { (snapshot) in
            var newItems = [Recipe]()
            for item in snapshot.children {
                if ((item as! DataSnapshot).value as? NSDictionary) != nil {
                    let recipe = Recipe.init(item as! DataSnapshot)
                    newItems.append(recipe)
                }
            }
            
            if newItems.count == 0 {
                self.notifyView.isHidden = false
                return
            }
            
            self.notifyView.isHidden = true
            self.recipes = newItems
            self.collectedView.reloadData()
        }
        
        self.collectionImage.image = UIImage(named: "bg_welcome")
        self.nameLabel.text = collectionName
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

extension RecipeCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.size.width / 2 - 11
        return CGSize(width: w, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "StepByStep", bundle: nil)
        let sbsCompletedController = storyBoard.instantiateViewController(withIdentifier: "StepByStepViewController") as! StepByStepViewController
        
        sbsCompletedController.recipeId = recipe.recipeId
        
        self.present(sbsCompletedController, animated: true, completion: nil)
    }
}
