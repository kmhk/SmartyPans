//
//  NotificationView.swift
//  SmartyPans
//
//  Created by com on 6/23/19.
//  Copyright © 2019 KMHK. All rights reserved.
//

import UIKit
import SDWebImage

class NotificationView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var imageView: UIImageView?
    var label: UILabel?

    static func showNotification(parent: UIViewController, image: UIImage, string: NSAttributedString) {
        let view = NotificationView(frame: CGRect(x: 10, y: parent.view.frame.size.height - 110, width: parent.view.frame.size.width - 20, height: 60))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.imageView?.image = image
        view.label?.attributedText = string
        
        view.show(parent: parent)
    }
    
    static func showNotification(parent: UIViewController, imageURL: String, string: NSAttributedString) {
        let view = NotificationView(frame: CGRect(x: 10, y: parent.view.frame.size.height - 110, width: parent.view.frame.size.width - 20, height: 60))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.imageView?.sd_setImage(with: URL(string: imageURL), completed: nil)
        view.label?.attributedText = string
        
        view.show(parent: parent)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        imageView!.layer.cornerRadius = 5
        imageView!.clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
        self.addSubview(imageView!)
        
        label = UILabel(frame: CGRect(x: 60, y: 0, width: self.frame.size.width - 70, height: 60))
        self.addSubview(label!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(parent: UIViewController) {
        parent.view.addSubview(self)
        self.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { (flag) in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseInOut, animations: {
                self.alpha = 0
            }, completion: { (flag) in
                self.removeFromSuperview()
            })
        }
    }
}
