//
//  Global.swift
//  Smartypans
//
//  Created by Lucky on 11/07/2018.
//  Copyright © 2018 SmartyPans Inc. All rights reserved.
//

import Foundation
import UIKit

var g_bStarted = false
let MFDemoErrorDomain = "MFDemoErrorDomain"
let MFDemoErrorCode = 100

func showOkAlert(title: String, msg: String, vc:UIViewController){
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}

func errorWithLocalizedDescription(localizedDescription: String) -> Error{
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain:MFDemoErrorDomain, code:MFDemoErrorCode, userInfo:userInfo)
}

func validateEmail(email: String)->Bool{
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with:email)
}

func getIndexPathOf(subview: UIView, tableView: UITableView) ->IndexPath{
    var view = subview
    while !(view is UITableViewCell) {
        view = view.superview!
    }
    return tableView.indexPath(for: view as! UITableViewCell)!
}

func setRound(toView: UIView, radius: CGFloat){
    toView.layer.cornerRadius = radius
    toView.clipsToBounds = true
}

func setPadding(toTextField: UITextField, fLeft: CGFloat, fRight: CGFloat){
    toTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: fLeft, height: 0))
    toTextField.leftViewMode = .always
    
    toTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: fRight, height: 0))
    toTextField.rightViewMode = .always
}

func setBottomBorder(textField:UITextField){
    let border = CALayer()
    let width = CGFloat(1.0)
    border.borderColor = UIColor.white.cgColor
    border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: textField.frame.size.height)
    
    border.borderWidth = width
    textField.layer.addSublayer(border)
    textField.layer.masksToBounds = true
}

func getDateFromString(dateString: String) -> Date{
    let dateFormatter = ISO8601DateFormatter()
    let date = dateFormatter.date(from:dateString)!
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    let finalDate = calendar.date(from:components)
    
    return finalDate!
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func topSafeAreaInsets() -> CGFloat {
    if let window = UIApplication.shared.keyWindow {
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets.top
        }
    }
    return 0
}
