//
//  UIAlertController+Extension.swift
//  SmartyPans
//
//  Created by com on 6/21/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    func addViewContoller(_ vc: UIViewController, width: CGFloat? = nil, height: CGFloat? = nil) {
        set(vc: vc, width: width, height: height)
    }
    
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}
