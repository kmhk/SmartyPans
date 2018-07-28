//
//  StepByStepCompletedViewController.swift
//  SmartyPans
//
//  Created by Mauro Taroco on 7/27/18.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class StepByStepCompletedViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var doneBtn: UIButton!
    @IBOutlet var shareBtn: UIButton!
    @IBOutlet var kcalBtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI(){
        setRound(toView: imgView, radius: imgView.bounds.width/2)
        setRound(toView: doneBtn, radius: 25)
        doneBtn.setBorder(borderWidth: 2, color: .white)
        setRound(toView: shareBtn, radius: shareBtn.bounds.width/2)
        setRound(toView: kcalBtn, radius: kcalBtn.bounds.width/2)
        shareBtn.dropCircleButtonShadow()
        kcalBtn.dropCircleButtonShadow()
    }
}
