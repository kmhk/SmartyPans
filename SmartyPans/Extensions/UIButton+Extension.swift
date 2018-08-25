//
//  UIButton+Extension.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 7/29/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
//    func applyGradient(colours: [UIColor]) -> Void {
//        self.applyHorizontalGradient(colours)
//    }
    
    func applyRedButtonGradient(gradient: CAGradientLayer) -> Void {
        
        let colours: [UIColor] = [hexStringToUIColor(hex: "FC6E72"), hexStringToUIColor(hex: "E22444")]
        
//        gradient.frame = self.bounds
//        gradient.colors = colours.map { $0.cgColor }
//        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.5)
//        gradient.endPoint = CGPoint.init(x: 1.0, y: 0.5)
        
        self.applyHorizontalGradient(gradient: gradient, colours: colours)
        
        if let imageView = self.imageView {
            self.bringSubview(toFront: imageView)
        }
    }
    
    func applyHorizontalGradient(gradient: CAGradientLayer, colours: [UIColor]) -> Void {
        //let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint.init(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
}
