//
//  SPBottomButton.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/19/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class SPBottomButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }
    
    func applyStyle() {
        applyRedButtonGradient()
        self.setTitleColor(.white, for: .normal)
        //self.setTitleColor(.redSPColor, for: .highlighted)
        
    }

}
