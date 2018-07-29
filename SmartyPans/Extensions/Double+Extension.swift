//
//  Double+Extension.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 7/28/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
