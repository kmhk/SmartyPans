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
    
    func dropSmallCircleButtonShadow() {
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func dropBigButtonShadow() {
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func dropCoolShadow(){
        self.layer.masksToBounds = false
        //self.backgroundColor = .white
        self.layer.cornerRadius = 14
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func applyBlackAndClearGradient() {
        self.applyGradient(colours: [.black, .clear, .black], locations: [0.0, 0.5, 1.0], alpha: 0.5)
    }
    
//    func applyGradient(colours: [UIColor]) -> Void {
//        self.applyGradient(colours: colours, locations: nil)
//    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?, alpha: CGFloat = 1) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        self.alpha = alpha
    }
    
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
}
