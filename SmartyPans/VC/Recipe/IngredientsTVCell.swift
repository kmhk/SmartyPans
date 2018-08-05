//
//  IngredientsTVCell.swift
//  Smartypans
//
//  Created by Lucky on 04/06/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import UIKit

class IngredientsTVCell: UITableViewCell {

    @IBOutlet weak var view : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView(){
        // Add Radius
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 1, height: 1)
//        view.layer.shadowRadius = 4.0
//        view.layer.shadowOpacity = 0.2
//        view.clipsToBounds = false
    }
}
