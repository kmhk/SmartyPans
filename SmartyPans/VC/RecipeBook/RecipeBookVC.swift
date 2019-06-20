//
//  RecipeBookVC.swift
//  SmartyPans
//
//  Created by com on 6/20/2019 AP.
//  Copyright © KMHK. All rights reserved.
//

import UIKit

class RecipeBookVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchBar: UISearchBar?
    
    var savedCollectionView: UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 56))
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 50))
        searchBar?.barTintColor = UIColor(red: 244, green: 244, blue: 244, av: 1.0)
        searchBar?.isTranslucent = false
        searchBar?.placeholder = "Search"
        searchView.addSubview(searchBar!)
        //collectionView.tableHeaderView = searchView
        
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//        }
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
            return 5
        }
        
        if section == 0 { // always return 1 for collected list
            return 1
        }
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == savedCollectionView {
            let header = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            return header
        }
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RBCollectionRegularHV", for: indexPath)
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.size.width - 20, height: headerView.frame.size.height))
            label.font = UIFont(name: "NunitoSans-Bold", size: 22)
            label.textColor = UIColor.black
            headerView.addSubview(label)
            
            if indexPath.section == 0 {
                label.text = "Collections"
                
                let btnAdd = UIButton(frame: CGRect(x: headerView.frame.size.width - 50, y: 15, width: 30, height: 30))
                btnAdd.setImage(UIImage(named: "btnNewCollection"), for: .normal)
                headerView.addSubview(btnAdd)
            } else {
                label.text = "Saved Items"
            }
            
            return headerView
        }
        
        assert(false, "Invalid RBCollectionView element type")
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
        if collectionView == savedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RBCollectedCVCell", for: indexPath)
            let recipeImageView = UIImageView(frame: cell.bounds)
            recipeImageView.image = UIImage(named: "collectionThumb")
            cell.addSubview(recipeImageView)
            
            return cell
        }
        
        if indexPath.section == 0 { // collected
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
            
        } else { // saved
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RBSavedCollectionCell", for: indexPath) as! RBSavedCVCell
            cell.recipeImage.image = UIImage(named: "bg_app")
            cell.creatorImage.image = UIImage(named: "logo_I")
            cell.creatorLabel.text = "abasdf"
            cell.nameLabel.text = "asdfsadf"
            return cell
            
        }
    }
}
