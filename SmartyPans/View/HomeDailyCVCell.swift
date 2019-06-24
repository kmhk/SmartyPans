//
//  HomeDailyCVCell.swift
//  SmartyPans
//
//  Created by com on 6/24/19.
//  Copyright © 2019 Lucky. All rights reserved.
//

import UIKit

class HomeDailyCVCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage : UIImageView!
    @IBOutlet weak var creatorImage : UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //recipeImage.layer.cornerRadius = 4
        //recipeImage.clipsToBounds = true
        
        self.creatorImage.layer.cornerRadius = self.creatorImage.frame.size.width / 2
        self.creatorImage.clipsToBounds = true
    }
}
