//
//  SPBottomButton.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/19/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class SPBottomButton: UIButton {

    let gradient: CAGradientLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }
    
    func applyStyle() {
        applyRedButtonGradient(gradient: gradient)
        self.setTitleColor(.white, for: .normal)
        //self.setTitleColor(.redSPColor, for: .highlighted)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }

}
