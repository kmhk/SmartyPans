//
//  PanCVCell.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 9/18/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation
class PanCVCell: UICollectionViewCell {
    @IBOutlet weak var panImage : UIImageView!

    @IBOutlet weak var panLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    var actionConnect: (()->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
        setRound(toView: connectButton, radius: connectButton.frame.height/2)
    }
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        actionConnect?()
    }
    
}
