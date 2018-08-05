//
//  SPTabButton.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/4/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation
import UIKit

class SPTabButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }
    
    func applyStyle() {
        self.setTitleColor(.graySPColor, for: .normal)
        self.setTitleColor(.redSPColor, for: .highlighted)
        self.setTitleColor(.redSPColor, for: .selected)
    }
    
    override func layoutSubviews() {
        if state == .normal {
            titleLabel?.font = .nunitoSansRegularOfSize15
        }
        else if state == .highlighted {
            titleLabel?.font = .nunitoSansBoldOfSize15
        }
        else if state == .disabled {
            titleLabel?.font = .nunitoSansRegularOfSize15
        }
        else if state == .selected {
            titleLabel?.font = .nunitoSansBoldOfSize15
        }
        
        super.layoutSubviews()
    }
}
