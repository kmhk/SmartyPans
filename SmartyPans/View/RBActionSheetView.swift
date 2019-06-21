//
//  RBActionSheetView.swift
//  SmartyPans
//
//  Created by com on 6/21/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

import UIKit

class RBActionSheetView: UIView, UIGestureRecognizerDelegate {
    
    var parentVC: UIViewController?
    var handler: ((_ index: Int)->())?
    var shareHandler: (() ->())?
    var images: [UIImage]?
    var btnNames: [String]?
    var box: UIView?

    static func show(parent: UIViewController, title: String, images: [UIImage], btnNames: [String], flag: Bool, handler: ((_ index: Int)->())?) -> RBActionSheetView {
        let container = RBActionSheetView(frame: parent.view.bounds)
        container.parentVC = parent
        container.handler = handler
        container.images = images
        container.btnNames = btnNames
        container.backgroundColor = UIColor(hex: 0x000000, alpha: 0.3)
        
        let gesture = UITapGestureRecognizer(target: container, action: #selector(onTapView(sender:)))
        gesture.delegate = container
        container.addGestureRecognizer(gesture)
        
        let h: CGFloat = (flag == true) ? 320 : 180
        
        container.box = UIView(frame: CGRect(x: 0, y: container.frame.size.height - h + 10, width: container.frame.size.width, height: h))
        container.box!.backgroundColor = UIColor.white
        container.box!.layer.cornerRadius = 15
        container.box!.clipsToBounds = true
        container.addSubview(container.box!)
        
        var lbl = UILabel(frame: CGRect(x: 0, y: 20, width: container.frame.size.width, height: 20))
        lbl.font = UIFont(name: "NunitoSans-Bold", size: 15)
        lbl.textAlignment = .center
        lbl.textColor = UIColor.black
        lbl.text = title
        container.box!.addSubview(lbl)
        
        let tableView = UITableView(frame: CGRect(x: 5, y: 60, width: container.frame.size.width - 10, height: 100))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RBActionSheetTableCell")
        tableView.dataSource = container
        tableView.delegate = container
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        if btnNames.count <= 2 {
            tableView.isScrollEnabled = false
        }
        container.box!.addSubview(tableView)
        
        if flag == true { // show social sharing buttons
            lbl = UILabel(frame: CGRect(x: 30, y: 180, width: container.frame.size.width - 50, height: 20))
            lbl.font = UIFont(name: "NunitoSans-Bold", size: 15)
            lbl.textColor = UIColor.black
            lbl.text = "Share"
            container.box!.addSubview(lbl)
            
            var btn = UIButton(frame: CGRect(x: 30, y: 220, width: 50, height: 50))
            btn.setImage(UIImage(named: "shareMessage"), for: .normal)
            container.box?.addSubview(btn)
            
            lbl = UILabel(frame: CGRect(x: btn.frame.minX, y: btn.frame.maxY + 5, width: btn.frame.size.width, height: 10))
            lbl.font = UIFont(name: "NunitoSans-Regular", size: 11)
            lbl.textColor = UIColor.black
            lbl.textAlignment = .center
            lbl.text = "Message"
            container.box!.addSubview(lbl)
            
            btn = UIButton(frame: CGRect(x: 120, y: 220, width: 50, height: 50))
            btn.setImage(UIImage(named: "shareMail"), for: .normal)
            container.box?.addSubview(btn)
            
            lbl = UILabel(frame: CGRect(x: btn.frame.minX, y: btn.frame.maxY + 5, width: btn.frame.size.width, height: 10))
            lbl.font = UIFont(name: "NunitoSans-Regular", size: 11)
            lbl.textColor = UIColor.black
            lbl.textAlignment = .center
            lbl.text = "Mail"
            container.box!.addSubview(lbl)
            
            btn = UIButton(frame: CGRect(x: 210, y: 220, width: 50, height: 50))
            btn.setImage(UIImage(named: "btnSetting"), for: .normal)
            btn.addTarget(container, action: #selector(moreBtnTapped(sender:)), for: .touchUpInside)
            container.box?.addSubview(btn)
            
            lbl = UILabel(frame: CGRect(x: btn.frame.minX, y: btn.frame.maxY + 5, width: btn.frame.size.width, height: 10))
            lbl.font = UIFont(name: "NunitoSans-Regular", size: 11)
            lbl.textColor = UIColor.black
            lbl.textAlignment = .center
            lbl.text = "More"
            container.box!.addSubview(lbl)
        }
        
        parent.view.addSubview(container)
        container.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            container.alpha = 1
        }) { (flag) in
            
        }
        
        return container
    }
    
    @objc func moreBtnTapped(sender: Any) {
        if let shareHandler = self.shareHandler {
            onTapView(sender: self)
            shareHandler()
        }
    }
    
    @objc func onTapView(sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (flag) in
            self.removeFromSuperview()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pt = gestureRecognizer.location(in: self)
        return !((box?.frame.contains(pt))!)
    }
    
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImg!
    }
}

extension RBActionSheetView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return btnNames!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RBActionSheetTableCell")
        
        cell?.imageView?.image = self.resizeImage(image: images![indexPath.row], size: CGSize(width: 44, height: 40))
        cell?.imageView?.layer.cornerRadius = 5
        cell?.imageView?.clipsToBounds = true
        
        cell?.textLabel?.text = btnNames![indexPath.row]
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel?.font = UIFont(name: "NunitoSans-Bold", size: 14)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.handler!(indexPath.row)
        self.onTapView(sender: self)
    }
}
