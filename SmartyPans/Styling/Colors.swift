//
//  Colors.swift
//  Mauro Taroco
//
//  Created by Mauro Taroco on 9/30/17.
//  Copyright © 2017 ThinkUp. All rights reserved.
//
import UIKit

private struct Color {
    static let redHex = 0xf1354d
    static let grayHex = 0xb7b7be
    
    
}

extension UIColor {
    
    // for these colors, just use UIColor.*Color()
    // black - 0x000000
    // white - 0xFFFFFF
    // red - 0xFF0000
    
    // Screens background color
    static let redSPColor = UIColor(hex: Color.redHex)
    static let graySPColor = UIColor(hex: Color.grayHex)
    
    
    // explains itself
    static let dimmedModalBackground = UIColor(white: 0x0, alpha: 0.7)
}
