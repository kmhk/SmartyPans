//
//  HomeRecipeTVCell.swift
//  SmartyPans
//
//  Created by com on 6/24/19.
//  Copyright © 2019 Lucky. All rights reserved.
//

import UIKit

class HomeRecipeTVCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage : UIImageView!
    @IBOutlet weak var creatorImage : UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var bkView: UIView!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.creatorImage.layer.cornerRadius = self.creatorImage.frame.size.width / 2
        self.creatorImage.clipsToBounds = true
        
        self.containerView.layer.cornerRadius = 30
        self.containerView.clipsToBounds = true
        
        self.bkView.layer.cornerRadius = 30
        self.bkView.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            self.containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
            
            
            //self.bkView.layer.maskedCorners = [.layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
