//
//  RBSavedCVCell.swift
//  SmartyPans
//
//  Created by com on 6/20/2019 AP.
//  Copyright © KMHK. All rights reserved.
//

import UIKit

class RBSavedCVCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage : UIImageView!
    @IBOutlet weak var creatorImage : UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recipeImage.layer.cornerRadius = 4
        recipeImage.clipsToBounds = true

        self.creatorImage.layer.cornerRadius = 15
        self.creatorImage.clipsToBounds = true
    }
}
