//
//  HomeCVCell.swift
//  Smartypans
//
//  Created by Lucky on 03/06/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit

class HomeCVCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage : UIImageView!
    @IBOutlet weak var creatorImage : UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recipeImage.layer.cornerRadius = 4
        recipeImage.clipsToBounds = true
        
        self.creatorImage.layer.cornerRadius = 15
        self.creatorImage.clipsToBounds = true
    }
    
    
}
