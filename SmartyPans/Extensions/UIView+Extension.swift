//
//  UIView+Extension.swift
//  Smartway
//
//  Created by Mauro Taroco on 10/28/17.
//  Copyright © 2017 ThinkUp. All rights reserved.
//

import UIKit

extension UIView {
    
    func setBorder(borderWidth: CGFloat, color: UIColor){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }
    
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropCircleButtonShadow() {
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.15
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
}
