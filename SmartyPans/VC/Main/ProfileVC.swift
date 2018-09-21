//
//  ProfileVC.swift
//  SmartyPans
//
//  Created by Lucky on 2018/7/24.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfileVC: UIViewController {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRecipeCnt: UILabel!
    
    @IBOutlet weak var btnAddRecipe: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewNone: UIView!
    
    var user: SUser!
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setRound(toView: btnAddRecipe, radius: 25)
        setRound(toView: imgProfile, radius: 64)
        imgProfile.layer.borderWidth = 8
        imgProfile.layer.borderColor = UIColor.white.cgColor
        showView()
        fetchUser()
        fetchMyPosts()
    }

    @IBAction func onLogout(_ sender: Any) {
        let alert = UIAlertController.init(title: "Confirm", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction.init(title: "NO", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        
        let logoutAction = UIAlertAction.init(title: "YES", style: .default) { (action) in
            do{
                try Auth.auth().signOut()
                MainTabBarVC.shared.loadLogin(animate: true)

            }catch{
                
            }
        }
        
        alert.addAction(logoutAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    func fetchUser() {
        Api.SUser.observeCurrentUser { (user) in
            self.user = user
            self.lblName.text = user.name
            if let profileUrl = URL(string: user.profileImageUrl!) {
                //self.imgProfile.sd_setImage(with: profileUrl)
                self.imgProfile.sd_setImage(with: profileUrl, placeholderImage: UIImage(named: "tab_profile_g"), options: SDWebImageOptions.continueInBackground, completed: nil)
            }
            
            if let bgUrl = URL(string: user.bgImageUrl!) {
                self.imgHeader.sd_setImage(with: bgUrl)
            }
            //self.collectionView.reloadData()
        }
    }
    
    func fetchMyPosts() {
        guard let currentUser = Api.SUser.CURRENT_USER else {
            return
        }
        Api.MyPosts.REF_MYPOSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            Api.Post.observePost(withId: snapshot.key, completion: {
                post in
                self.posts.append(post)
                self.lblRecipeCnt.text = String(self.posts.count)
                self.showView()
                self.collectionView.reloadData()
            })
        })
    }
    
    func showView(){
        if(posts.count == 0){
            self.viewNone.isHidden = false
            self.collectionView.isHidden = true
        }else{
            self.viewNone.isHidden = true
            self.collectionView.isHidden = false
        }
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

}

extension ProfileVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellFeed", for: indexPath) as! HomeCVCell
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        
        let recipe = posts[indexPath.row]
        cell.nameLabel.text = recipe.name
        cell.creatorLabel.text = recipe.creator
        if let creatorImage = recipe.creatorImage {
            cell.creatorImage.sd_setImage(with: URL(string: creatorImage), completed: nil)
        }
        if let recipeImage = recipe.recipeImage {
            cell.recipeImage.sd_setImage(with: URL(string: recipeImage), completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        let width = screenWidth / 2 - 11
        let height = CGFloat(200)
        
        return CGSize(width: width, height: height)
    }
}
