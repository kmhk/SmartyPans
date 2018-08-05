//
//  String+Extension.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 8/5/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

