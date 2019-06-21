//
//  RBAlertView.swift
//  SmartyPans
//
//  Created by com on 6/21/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

import UIKit

class RBAlertView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var collectionName: UITextField?
    var parentVC: UIViewController?
    var handler: ((String) -> ())?
    
    static func showWithTextField(parent: UIViewController, title: String, value: String, handler: @escaping ((String) -> ())) {
        let container = RBAlertView(frame: parent.view.bounds)
        container.parentVC = parent
        container.handler = handler
        container.backgroundColor = UIColor(hex: 0x000000, alpha: 0.3)
        
        let alert = UIView(frame: CGRect(x: 20, y: 125, width: container.frame.size.width - 40, height: 185))
        alert.backgroundColor = UIColor.white
        alert.layer.cornerRadius = 15
        alert.clipsToBounds = true
        container.addSubview(alert)
        
        var label = UILabel(frame: CGRect(x: 0, y: 30, width: alert.frame.size.width, height: 30))
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.redSPColor
        label.font = UIFont(name: "NunitoSans-Bold", size: 14)
        alert.addSubview(label)
        
        label = UILabel(frame: CGRect(x: 10, y: 80, width: alert.frame.size.width - 20, height: 20))
        label.text = "COLLECTION NAME"
        label.textColor = UIColor.graySPColor
        label.font = UIFont(name: "NunitoSans-Regular", size: 11)
        alert.addSubview(label)
        
        container.collectionName = UITextField(frame: CGRect(x: 10, y: 95, width: alert.frame.size.width - 20, height: 40))
        container.collectionName?.font = UIFont(name: "NunitoSans-Regular", size: 15)
        container.collectionName?.returnKeyType = .done
        container.collectionName?.text = value
        alert.addSubview(container.collectionName!)
        
        label = UILabel(frame: CGRect(x: 10, y: 135, width: alert.frame.size.width - 20, height: 1))
        label.backgroundColor = UIColor.graySPColor
        alert.addSubview(label)
        
        let btnView = UIView(frame: CGRect(x: 0, y: 0, width: container.frame.size.width, height: 54))
        
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: container.frame.size.width / 2, height: btnView.frame.size.height))
        cancelBtn.setTitle("CANCEL", for: .normal)
        cancelBtn.setTitleColor(UIColor.redSPColor, for: .normal)
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
        cancelBtn.addTarget(container, action: #selector(cancelBtnTap(sender:)), for: .touchUpInside)
        btnView.addSubview(cancelBtn)
        
        let okBtn = UIButton(frame: CGRect(x: container.frame.size.width / 2, y: 0, width: container.frame.size.width / 2, height: btnView.frame.size.height))
        okBtn.setTitle("SAVE", for: .normal)
        okBtn.setTitleColor(UIColor.white, for: .normal)
        okBtn.backgroundColor = UIColor.redSPColor
        okBtn.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
        okBtn.addTarget(container, action: #selector(OkBtnTap(sender:)), for: .touchUpInside)
        btnView.addSubview(okBtn)
        
        container.collectionName?.inputAccessoryView = btnView
        container.collectionName?.autocorrectionType = .no
        
        parent.view.addSubview(container)
        container.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            container.alpha = 1
        }) { (flag) in
            container.collectionName?.becomeFirstResponder()
        }
    }
    
    
    static func showAlert(parent: UIViewController, title: String, msg: String, okTitle: String, noTitle: String, handler: @escaping ((String) -> ())) {
        let container = RBAlertView(frame: parent.view.bounds)
        container.parentVC = parent
        container.handler = handler
        container.backgroundColor = UIColor(hex: 0x000000, alpha: 0.3)
        
        let alert = UIView(frame: CGRect(x: 20, y: container.frame.size.height / 2 - 80, width: container.frame.size.width - 40, height: 205))
        alert.backgroundColor = UIColor.white
        alert.layer.cornerRadius = 15
        alert.clipsToBounds = true
        container.addSubview(alert)
        
        var label = UILabel(frame: CGRect(x: 0, y: 20, width: alert.frame.size.width, height: 30))
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.redSPColor
        label.font = UIFont(name: "NunitoSans-Bold", size: 15)
        alert.addSubview(label)
        
        label = UILabel(frame: CGRect(x: 50, y: 65, width: alert.frame.size.width - 100, height: 70))
        label.text = msg
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(name: "NunitoSans-Bold", size: 15)
        label.numberOfLines = 3
        alert.addSubview(label)
        
        let okBtn = UIButton(frame: CGRect(x: 0, y: 145, width: alert.frame.size.width / 2, height: 50))
        okBtn.setTitle(okTitle, for: .normal)
        okBtn.setTitleColor(UIColor.redSPColor, for: .normal)
        okBtn.backgroundColor = UIColor.clear
        okBtn.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
        okBtn.addTarget(container, action: #selector(OkBtnTap(sender:)), for: .touchUpInside)
        alert.addSubview(okBtn)
        
        let cancelBtn = UIButton(frame: CGRect(x: alert.frame.size.width / 2, y: 145, width: alert.frame.size.width / 2, height: 50))
        cancelBtn.setTitle(noTitle, for: .normal)
        cancelBtn.setTitleColor(UIColor.graySPColor, for: .normal)
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.titleLabel?.font = UIFont(name: "NunitoSans-Bold", size: 16)
        cancelBtn.addTarget(container, action: #selector(cancelBtnTap(sender:)), for: .touchUpInside)
        alert.addSubview(cancelBtn)
        
        parent.view.addSubview(container)
        container.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            container.alpha = 1
        }) { (flag) in
            container.collectionName?.becomeFirstResponder()
        }
    }
    
    
    @objc func cancelBtnTap(sender: Any) {
        if collectionName != nil {
            collectionName?.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (flag) in
            self.removeFromSuperview()
        }
    }
    
    
    @objc func OkBtnTap(sender: Any) {
        if collectionName == nil {
            self.handler!("")
            self.cancelBtnTap(sender: self)
            return
        }
        
        if let text = collectionName?.text, text != "" {
            self.handler!(text)
            self.cancelBtnTap(sender: self)
        }
    }
}
